{
  lib,
  ...
}:
let
  inherit (lib.attrsets) genAttrs;
in
{
  image.modules =
    genAttrs
      [
        "sd-card"
        "iso"
      ]
      (name: {
        imports = [ ./${name} ];
      });
}
