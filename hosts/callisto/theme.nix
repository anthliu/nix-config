{ lib, ... }:

{
  imports = [ ../../modules/shared/matugen-wallpaper-palette.nix ];

  # One wallpaper choice feeds Stylix and its Matugen-derived palette in both the
  # NixOS and Home Manager configurations for this host.
  stylix.image = lib.mkForce ../../assets/cherry-blossoms-fuji.png;
}
