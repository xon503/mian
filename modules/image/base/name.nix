{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkImageMediaOverride;

  # Get the hostname from our networking name provided in the mkNixosIso builder
  # If none is set then default to "nixos"
  hostname = config.networking.hostName or "nixos";

  # We get the rev of the git tree here and if we don't have one that
  # must mean we have made local changes so we call the git tree "dirty"
  rev = self.shortRev or "dirty";

  # Give all the isos a consistent name
  # $hostname-$release-$rev-$arch
  name = "${hostname}-${config.system.nixos.release}-${rev}-${pkgs.stdenv.hostPlatform.uname.processor}";
in
{
  image = {
    # From the name defined before we end up with: name.iso
    baseName = mkImageMediaOverride name;
  };
}
