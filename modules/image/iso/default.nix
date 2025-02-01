# if your curious why we have no users, its because the nix iso default provides two users
# nixos and root, both with no passwords so we can change those after we boot into the iso
# https://github.com/NixOS/nixpkgs/blob/90a153e81e7deb0b2ea1466c8a2f515df1974717/nixos/modules/profiles/installation-device.nix#L32
{
  imports = [
    ./base.nix # the base iso image
    ./boot.nix # boot settings
    ./fixes.nix # fixes issues
    ./iso.nix # the iso image and its configuration
    ./programs.nix # programs that we will need to make our NixOS install
  ];
}
