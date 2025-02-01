{
  imports = [
    ./console.nix # tty configurations
    ./hardware.nix # include some drivers
    ./name.nix # set the name for the image
    ./networking.nix # all access to the outside
    ./space.nix # ways that we save valuable space on the image
  ];
}
