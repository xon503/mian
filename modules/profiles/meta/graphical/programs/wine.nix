{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.programs) mkProgram;
  inherit (lib.validators) isWayland;
  inherit (lib.lists) optional;

  cfg = config.garden.programs.wine;
in
{
  options.garden.programs.wine = mkProgram pkgs "wine" {
    package.default =
      if isWayland config then pkgs.wineWowPackages.waylandFull else pkgs.wineWowPackages.stableFull;
  };

  # determine which version of wine to use
  config.environment.systemPackages = optional cfg.enable cfg.package;
}