{ pkgs, ... }:

{
  # Kept separate because the toolchain is large and flashing requires direct
  # access to a keyboard's USB bootloader device.
  home.packages = [ pkgs.qmk ];
}
