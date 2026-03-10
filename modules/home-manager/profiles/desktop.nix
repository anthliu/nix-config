{ pkgs, inputs, lib, options, ... }:

{
  imports = [
    ../features/niri.nix
    ../features/swayidle.nix
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "none";
      };
    };
    # Stylix will automatically configure fonts and colors
  };

  programs.foot = {
    enable = true;
    settings = {
      csd = {
        preferred = "none";
        size = 0;
      };
    };
    # Stylix will automatically configure fonts and colors
  };

  home.packages = [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.google-chrome
    pkgs.vlc
    pkgs.discord
    pkgs.shotcut
  ];

  home.shellAliases = {
    igpu-chrome = "env LIBVA_DRIVER_NAME=radeonsi __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json __GLX_VENDOR_LIBRARY_NAME=mesa google-chrome-stable --render-node-override=/dev/dri/renderD129";
  };

  programs.mpv = {
    enable = true;
    config = {
      autofit-larger = "100%x100%";
      loop-file = "inf";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
    };
  };
}
