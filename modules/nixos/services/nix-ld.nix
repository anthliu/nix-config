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
    gtk3
    libsecret
    nss

    # for OpenCV / cv2:
    libSM
    libICE
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrandr
    fontconfig
    freetype
    libglvnd
    libxcb

    # for JAX/CUDA:
    linuxPackages.nvidia_x11
    # sometimes required:
    xorg.libXi
    xorg.libXmu
    libGL
  ];
}
