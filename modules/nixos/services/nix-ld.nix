{ pkgs, ... }:

{
  # --- Nix-ld Configuration ---
  # Required for tools like uv that download and run unpatched binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    libgcc
    glib

    # for JAX/CUDA:
    linuxPackages.nvidia_x11
    # sometimes required:
    xorg.libXi
    xorg.libXmu
    libGL
  ];
}
