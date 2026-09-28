{ lib, ... }:

{
  imports = [ ../../modules/shared/matugen-wallpaper-palette.nix ];

  stylix.image = lib.mkForce ../../assets/cherry-blossoms-fuji.png;
}
