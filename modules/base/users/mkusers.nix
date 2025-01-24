{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault;
  inherit (lib.attrsets) genAttrs attrNames;
  inherit (lib.hardware) ldTernary;
  inherit (lib.validators) ifTheyExist;

  hm = config.home-manager.users;
  users = attrNames config.garden.system.users;
in
{
  users.users = genAttrs users (
    name:
    {
      home = "/" + (ldTernary pkgs "home" "Users") + "/" + name;
      shell = hm.${name}.garden.programs.${hm.${name}.garden.programs.defaults.shell}.package;
    }
    // (ldTernary pkgs {
      uid = mkDefault 1000;
      isNormalUser = true;
      initialPassword = mkDefault "changeme";

      # only add groups that exist
      extraGroups =
        [
          "wheel"
          "nix"
        ]
        ++ ifTheyExist config [
          "network"
          "networkmanager"
          "systemd-journal"
          "audio"
          "pipewire" # this give us access to the rt limits
          "video"
          "input"
          "plugdev"
          "lp"
          "tss"
          "power"
          "wireshark"
          "mysql"
          "docker"
          "podman"
          "git"
          "libvirtd"
          "cloudflared"
        ];
    } { })
  );
}
