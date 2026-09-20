{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    playerctl
    mako
    libnotify

    kdePackages.polkit-kde-agent-1

    fuzzel
    thunar
    thunar-archive-plugin
    thunar-volman
    xfconf
    tumbler
    ffmpegthumbnailer
    feh
    zathura
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
}
