{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "256M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
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
          };
        };
      };

      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/srv/storage";
              };
            };
          };
        };
      };

      swap = {
        type = "disk";
        device = "/dev/zram0";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                # resume from hibernation from this device
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
  };
}
