{
  lib,
  pkgs,
  self,
  self',
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.lists) optionals;
  inherit (lib.types)
    enum
    submoduleWith
    attrsOf
    anything
    ;
  inherit (lib.attrsets) attrNames mapAttrs;

  userType = submoduleWith {
    specialArgs = {
      inherit lib self inputs;
    };

    modules = [
      ./programs

      {
        config._module = {
          freeformType = attrsOf anything;

          args = {
            osConfig = config;
            inherit pkgs self' inputs';
          };
        };
      }
    ];
  };
in
{
  options.garden.system = {
    mainUser = mkOption {
      type = enum (attrNames config.garden.system.users);
      description = "The username of the main user for your system";
      default = "isabel";
    };

    users = mkOption {
      type = attrsOf userType;
      default = { };
      description = ''
        A list of users that you wish to declare as your non-system users. The first username
        in the list will be treated as your main user unless {option}`garden.system.mainUser` is set.
      '';
    };
  };

  config = {
    # map our garden users to our home-manager users, so its easier to access those options
    home-manager.users = mapAttrs (_: conf: {
      options.garden = mkOption {
        type = userType;
        default = conf.garden;
      };
    }) config.garden.system.users;

    warnings = optionals (config.garden.system.users == { }) [
      ''
        You have not added any users to be supported by your system. You may end up with an unbootable system!

        Consider setting {option}`config.garden.system.users` in your configuration
      ''
    ];
  };
}
