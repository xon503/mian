{ inputs, ... }:
{
  # We don't want to alter the iso image itself so we prevent rebuilds
  system.switch.enable = false;

  # fixes "too many open files"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "65536";
    }
  ];

  # fix annoying warnings
  environment.etc = {
    "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;

    "mdadm.conf".text = ''
      MAILADDR root
    '';
  };
}
