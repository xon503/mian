{
  config,
  lib,
  ...
}: let
  smb = config.modules.services.smb;
in {
  config = lib.mkIf ((smb.enable) && (smb.recive.general)) {
    fileSystems."/mnt/general" = {
      device = "//192.168.86.4/sharedata";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.after=network-online.target"
        "x-systemd.mount-timeout=90"
        "uid=1000"
        "gid=1000"
      ];
    };
  };
}
