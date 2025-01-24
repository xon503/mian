{ lib, config, ... }:
let
  inherit (lib.lists) map any;
  inherit (lib.attrsets) attrNames;
  inherit (lib.trivial) id;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;

  users = attrNames config.garden.system.users;

  isAllowed = item: any id (map (user: config.garden.users.${user}.programs.${item}.enable) users);
in
{
  options.garden.meta = {
    zsh = mkOption {
      default = isAllowed "zsh";
      description = "Enable zsh";
      type = bool;
    };

    fish = mkOption {
      default = isAllowed "fish";
      description = "Enable fish";
      type = bool;
    };

    thunar = mkOption {
      default = isAllowed "thunar";
      description = "Enable Thunar";
      type = bool;
    };

    kdeconnect = mkOption {
      default = isAllowed "kdeconnect";
      description = "Enable KDE Connect";
      type = bool;
    };

    gui = mkOption {
      default = isAllowed "gui";
      description = "Enable GUI programs";
      type = bool;
    };
  };
}
