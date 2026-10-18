# Single source of truth for the patched niri build, shared by the NixOS
# module (modules/nixos/desktop/niri-base.nix) and the home-manager feature
# (modules/home-manager/features/niri.nix).
{ pkgs }:

pkgs.niri.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ../patches/niri-middle-click-drag.patch
  ];
})
