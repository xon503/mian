{
  lib,
  self,
  self',
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
in
{
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";

    extraSpecialArgs = {
      inherit
        self
        self'
        inputs
        inputs'
        ;
    };

    users = mapAttrs (name: _: ./${name}) config.garden.system.users;

    # we should define grauntied common modules here
    sharedModules = [
      inputs.beapkgs.homeManagerModules.default

      ./base/default.nix
    ];
  };
}
