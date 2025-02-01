{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  networking = {
    # use networkmanager in the live environment
    networkmanager = {
      enable = true;
      # we don't want any plugins, they only takeup space
      # you might consider adding some if you need a VPN for example
      plugins = mkForce [ ];
    };

    wireless.enable = false;
  };

  # allow ssh into the system for headless installs
  systemd.services.sshd.wantedBy = mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
  ];
}
