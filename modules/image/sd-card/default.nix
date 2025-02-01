{ inputs, ... }:
{
  imports = [
    ../base

    # bring in the raspberry pi module
    (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-raspberrypi-installer.nix")
  ];

  config.nixpkgs.buildPlatform.system = "x86_64-linux";
}
