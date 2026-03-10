{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/desktop.nix
    ../../modules/nixos/services/stylix.nix
  ];

  # Home Manager needs to know who you are
  home.username = "anthliu";
  home.homeDirectory = "/home/anthliu";

  # Install user-specific packages here
  home.packages = with pkgs; [
    # Explicitly install Home Manager CLI
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager

    # Hardware-specific packages
    (writeShellScriptBin "igpu-chrome" ''
      exec env LIBVA_DRIVER_NAME=radeonsi \
        __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
        __GLX_VENDOR_LIBRARY_NAME=mesa \
        google-chrome-stable \
        --render-node-override=/dev/dri/renderD129 \
        --disable-zero-copy \
        --disable-gpu-rasterization \
        --disable-features=Vulkan,VaapiVideoDecodeLinuxGL \
        --use-gl=egl \
        "$@"
    '')
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # State version for Home Manager (similar to NixOS system.stateVersion)
  home.stateVersion = "25.11"; 
} 
