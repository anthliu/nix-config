{ pkgs, ... }:

{
  # Baseline compatibility libraries for unpatched binaries downloaded by
  # tools such as uv. GPU runtimes are composed separately per host.
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
    # Sometimes required by GUI and hardware-aware binaries.
    libxi
    libxmu
    libGL
    pciutils
  ];
}
