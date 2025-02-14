{
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/01D925D0893A60B0";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
    ];
  };

  disko.devices = {
    disk = {
      nvme1n1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              start = "2MiB";
              end = "514MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              start = "-8.80Gib";
              end = "-2.49MiB";
              content.type = "swap";
            };
          };
        };
      };
    };
  };
}
