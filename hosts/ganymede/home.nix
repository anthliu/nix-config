{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/graphical.nix
    ../../modules/home-manager/features/local-ai.nix
    ../../modules/home-manager/features/niri.nix
    ../../modules/home-manager/features/qmk.nix
    ../../modules/home-manager/features/swayidle.nix
    ../../modules/shared/stylix.nix
  ];

  home.packages = with pkgs; [
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

  programs.niri.settings.outputs = {
    "Dell Inc. AW3423DWF BDRK2S3" = {
      mode = {
        width = 3440;
        height = 1440;
        refresh = 164.900;
      };
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };

    "Samsung Electric Company Odyssey G81SF HNBYA00490" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 239.996;
      };
      scale = 1.25;
      position = {
        x = 3440;
        y = 0;
      };
    };
  };

  xdg.desktopEntries = {
    google-chrome-igpu = {
      name = "Google Chrome (iGPU)";
      genericName = "Web Browser";
      exec = "google-chrome-igpu %U";
      icon = "google-chrome";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
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

  home.stateVersion = "25.11";
}
