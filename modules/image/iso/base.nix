{ inputs, ... }:
{
  imports = [
    ../base

    (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix")
  ];
}
