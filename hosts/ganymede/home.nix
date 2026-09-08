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
    (writeShellScriptBin "google-chrome-igpu" ''
      # Render Chrome on the AMD iGPU so it doesn't consume RTX 3090 VRAM (frees
      # VRAM for local AI on the NVIDIA GPU). --render-node-override pins the GPU;
      # runs native Wayland so it picks up the dark GTK theme (XWayland apps get no
      # theme here - no xsettings daemon) and renders correctly. AMD->NVIDIA buffer
      # display across GPUs works fine, so XWayland is not needed. Reference the
      # render node by stable PCI by-path: /dev/dri/renderD12X numbers can flip
      # between boots (this launcher used to hardcode renderD129 = NVIDIA).
      exec env LIBVA_DRIVER_NAME=radeonsi \
        __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
        __GLX_VENDOR_LIBRARY_NAME=mesa \
        google-chrome-stable \
        --ozone-platform=wayland \
        --render-node-override=/dev/dri/by-path/pci-0000:11:00.0-render \
        --disable-zero-copy \
        --disable-gpu-rasterization \
        --disable-features=Vulkan,VaapiVideoDecodeLinuxGL \
        --use-gl=egl \
        "$@"
    '')
  ];

  xdg.desktopEntries = {
    google-chrome-igpu = {
      name = "Google Chrome (iGPU)";
      genericName = "Web Browser";
      exec = "google-chrome-igpu %U";
      icon = "google-chrome";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/x-mimearchive"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    };
    slay-the-spire-2 = {
      name = "Slay the Spire 2";
      exec = "steam steam://rungameid/2868840";
      icon = "steam_icon_2868840";
      terminal = false;
      categories = [ "Game" ];
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # State version for Home Manager (similar to NixOS system.stateVersion)
  home.stateVersion = "25.11"; 
} 
