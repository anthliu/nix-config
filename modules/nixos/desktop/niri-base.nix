{ pkgs, inputs, ... }:

{
  imports = [ ./wayland-common.nix ];

  programs.niri = {
    enable = true;
    package = import ../../../packages/niri-patched.nix { inherit pkgs inputs; };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };
}
