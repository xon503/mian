{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./wm
    ./cli
    ./gui
    ./system
  ]; 
}