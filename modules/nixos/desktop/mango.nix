{ pkgs, inputs, ... }:

{
  imports = [
    inputs.mango.nixosModules.mango
  ];

  # --- Mango Compositor ---
  programs.mango.enable = true;

  # --- NVIDIA + wlroots workarounds ---
  # Mango uses wlroots which needs Vulkan renderer on NVIDIA (GLES2 is broken).
  # These are not needed for niri since it has its own renderer.
  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # --- DMS Shell ---
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

  # Fix: Ensure DMS can find quickshell (qs) and system utilities
  # We use the standard NixOS 'path' attribute which appends to the unit environment
  systemd.user.services.dms = {
    path = with pkgs; [
      quickshell
      bash
      coreutils
      gnugrep
      procps
      which
      "/run/wrappers"
    ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.StartLimitBurst = 10;
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
  environment.systemPackages = with pkgs; [
    quickshell # Needed for the DMS shell UI components
    xwayland-satellite

    playerctl
    mako
    libnotify # For notify-send

    # Auth Agent
    kdePackages.polkit-kde-agent-1 # plasma-polkit-agent
    
    # Default apps
    fuzzel
    thunar
    thunar-archive-plugin
    thunar-volman
    xfconf # For GTK settings
    tumbler
    feh
    zathura # pdf reader

    # DPMS control (wlroots-compatible)
    wlopm
  ];

  # --- Services ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Files
  services.gvfs.enable = true;

  # Volume management
  services.udisks2.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
 
  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Required for GTK settings/themes
  programs.dconf.enable = true;
}
