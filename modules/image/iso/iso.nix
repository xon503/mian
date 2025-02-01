{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkImageMediaOverride;
  inherit (lib.sources) cleanSource;
in
{

  garden.system.useHomeManager = false;

  isoImage = {
    # volumeID is used is used by stage 1 of the boot process, so it must be distintctive
    volumeID = mkImageMediaOverride config.image.baseName;

    # maximum compression, in exchange for build speed
    squashfsCompression = "zstd -Xcompression-level 19";

    # ISO image should be an EFI-bootable volume
    makeEfiBootable = true;

    # ISO image should be bootable from USB
    makeUsbBootable = true;

    # remove "-installer" boot menu label
    appendToMenuLabel = "";

    contents = [
      {
        # This should help for debugging if we ever get an unbootable system and have to
        # prefrom some repairs on the system itself
        source = pkgs.memtest86plus + "/memtest.bin";
        target = "/boot/memtest.bin";
      }
      {
        # we also provide our flake such that a user can easily rebuild without needing
        # to clone the repo, which needlessly slows the install process
        source = cleanSource self;
        target = "/flake";
      }
    ];
  };
}
