{ pkgs, inputs, config, lib, ... }:

{
  # --- Niri & DMS ---
  programs.niri = {
    enable = true;
    package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ../../../patches/niri-middle-click-drag.patch
      ];
    });
  };
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

  # --- Display Manager (greetd + ReGreet, rendered by niri) ---
  # NOTE: switched off GDM. GDM 50 (GNOME 50) fails to launch non-GNOME Wayland
  # sessions ("Unable to run session" / session never registers), which broke
  # niri login. greetd is a pure Wayland/console login daemon (no Xorg at all).
  # We render the graphical ReGreet greeter with niri itself (not cage), so the
  # login screen inherits the real session's multi-monitor/scaling setup and
  # isn't a TTY UI that late boot messages can corrupt. See nixpkgs#523332.
  programs.regreet.enable = true;
  # stylix themes ReGreet but only sets the font family, leaving ReGreet's
  # default size of 16 (huge on the 4K). Match the rest of the system.
  programs.regreet.font.size = config.stylix.fonts.sizes.applications;

  # Reboot / power-off buttons on the greeter (for when you're locked out of a
  # session). ReGreet hides these unless the commands are configured.
  programs.regreet.settings.commands = {
    reboot = [ "${lib.getExe' pkgs.systemd "systemctl"}" "reboot" ];
    poweroff = [ "${lib.getExe' pkgs.systemd "systemctl"}" "poweroff" ];
  };

  # Greeter niri config: launch ReGreet, and quit niri once it exits (login done).
  # Outputs mirror the real session (keep in sync with
  # modules/home-manager/features/niri.nix) so ReGreet renders at the correct
  # scale/DPI instead of a blurry/tiny 1.0 on the 4K.
  environment.etc."greetd/niri-greeter.kdl".text = ''
    spawn-sh-at-startup "${lib.getExe config.programs.regreet.package}; ${lib.getExe' config.programs.niri.package "niri"} msg action quit --skip-confirmation"

    hotkey-overlay {
        skip-at-startup
    }

    output "Dell Inc. AW3423DWF BDRK2S3" {
        mode "3440x1440@164.900"
        scale 1.0
        position x=0 y=0
    }

    output "Samsung Electric Company Odyssey G81SF HNBYA00490" {
        mode "3840x2160@239.996"
        scale 1.25
        position x=3440 y=0
    }
  '';

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe' pkgs.dbus "dbus-run-session"} ${lib.getExe' config.programs.niri.package "niri"} --config /etc/greetd/niri-greeter.kdl";
      user = "greeter";
    };
  };

  # --- Notification Daemon (Mako) ---
  # Niri doesn't come with a notification daemon, Mako is recommended
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    playerctl
    mako
    libnotify # For notify-send
    
    # Portals (Recommended for Niri)
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    gnome-keyring
    
    # Auth Agent
    kdePackages.polkit-kde-agent-1 # plasma-polkit-agent
    
    # Default apps
    fuzzel
    thunar
    thunar-archive-plugin
    thunar-volman
    xfconf # For GTK settings
    tumbler
    ffmpegthumbnailer # registers .thumbnailer so the GTK/portal file chooser (browser upload dialog) can make video thumbnails
    feh
    zathura # pdf reader
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

  # Files
  # Enable GVFS (needed for Trash, mounting, and identifying devices)
  services.gvfs.enable = true;

  # Enable UDisks2 (needed for volume management)
  services.udisks2.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
 
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
