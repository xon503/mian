{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  # reload system units when changing configs
  systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again
}
