# Single source of truth for the patched niri build, shared by the NixOS
# module (modules/nixos/desktop/niri.nix) and the home-manager feature
# (modules/home-manager/features/niri.nix).
{ pkgs, inputs }:

inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ../patches/niri-middle-click-drag.patch
  ];
})
