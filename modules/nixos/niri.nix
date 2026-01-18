{ pkgs, inputs, ... }:

{
  # --- Niri & DMS ---
  programs.niri.enable = true;
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true; 
    enableCalendarEvents = true;
  };

  # --- Display Manager (GDM) ---
  services.xserver.enable = true;
  services.displayManager.gdm = {
    enable = true;
    settings = {
      greeter = {
        Exclude = "root";
      };
    };
  };

  # --- Notification Daemon (Mako) ---
  # Niri doesn't come with a notification daemon, Mako is recommended
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    mako
    libnotify # For notify-send
    
    # Portals (Recommended for Niri)
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    gnome-keyring
    
    # Auth Agent
    kdePackages.polkit-kde-agent-1 # plasma-polkit-agent
    
    # Default apps
    alacritty
    fuzzel
    thunar
    tumbler
    feh
  ];

  # --- Services ---
  # Pipewire is already enabled in base/audio config usually, but good to ensure
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
 
  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Required for GTK settings/themes
  programs.dconf.enable = true;

  # --- Portals Configuration ---
  # Niri module usually handles xdg.portal.enable = true, but we ensure extra portals are present
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "gtk";
  };
}
