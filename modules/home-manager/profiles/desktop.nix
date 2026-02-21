{ pkgs, lib, options, ... }:

{
  imports = [
    ../features/niri.nix
    ../features/swayidle.nix
  ];

  programs.alacritty = {
    enable = true;
    # Stylix will automatically configure fonts and colors
  };

  home.packages = [
    pkgs.antigravity-fhs
    pkgs.google-chrome
    pkgs.vlc
    pkgs.shotcut
  ];

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
    };
  };
}
