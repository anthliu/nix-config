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
    libx11
    libxext
    libxrender
    libxfixes
    libxcursor
    libxcomposite
    libxdamage
    libxrandr
    fontconfig
    freetype
    libglvnd
    libxcb

    # for JAX/CUDA:
    linuxPackages.nvidia_x11
    cudaPackages.cuda_nvrtc
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    cudaPackages.cudatoolkit

    # sometimes required:
    libxi
    libxmu
    libGL
  ];
}
