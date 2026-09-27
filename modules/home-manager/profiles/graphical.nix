{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings.window.decorations = "none";
  };

  programs.foot = {
    enable = true;
    settings.csd = {
      preferred = "none";
      size = 0;
    };
  };

  home.packages = with pkgs; [
    fastfetch
    ffmpeg
    google-chrome
    lmstudio
    shotcut
    vesktop
    vlc
  ];

  programs.mpv = {
    enable = true;
    config = {
      autofit-larger = "100%x100%";
      loop-file = "inf";
    };
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default = {
      id = 0;
      isDefault = true;
    };
  };

  gtk.enable = true;
}
