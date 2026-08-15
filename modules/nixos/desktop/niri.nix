{ pkgs, inputs, config, lib, ... }:

{
  # --- Niri & DMS ---
  programs.niri = {
    enable = true;
    package = import ../../../packages/niri-patched.nix { inherit pkgs inputs; };
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

  # --- Display Manager (greetd + dms-greeter, rendered by niri) ---
  # NOTE: switched off GDM. GDM 50 (GNOME 50) fails to launch non-GNOME Wayland
  # sessions ("Unable to run session" / session never registers), which broke
  # niri login. greetd is a pure Wayland/console login daemon (no Xorg at all).
  # The greeter is rendered by niri itself (not cage), so the login screen
  # inherits the real session's multi-monitor/scaling setup and isn't a TTY UI
  # that late boot messages can corrupt. See nixpkgs#523332.
  #
  # dms-greeter reuses the DMS lock screen look and picks up our own theme.
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    # Syncs our DMS settings/session/colors into the greeter's data dir.
    configHome = "/home/anthliu";

    # Replaces the launcher's base config, which it skips when given one.
    # Outputs mirror modules/home-manager/features/niri.nix (keep in sync).
    compositor.customConfig = ''
      hotkey-overlay {
          skip-at-startup
      }

      environment {
          DMS_RUN_GREETER "1"
      }

      gestures {
          hot-corners {
              off
          }
      }

      layout {
          background-color "#000000"
      }

      // Idle management for the greeter: without this, a machine left sitting on
      // the login screen (e.g. after a reboot) never sleeps and wastes power.
      // Mirrors the real session (modules/home-manager/features/swayidle.nix):
      // blank the displays at 5 min, suspend at 15 min. The before-sleep /
      // after-resume power-on-monitors work around the nvidia-resume race that
      // otherwise corrupts niri's DRM state on wake (see niri-wm/niri#2139).
      // Store paths are required: the launcher's PATH has only qs and niri.
      spawn-sh-at-startup "${lib.getExe pkgs.swayidle} -w timeout 300 '${lib.getExe' config.programs.niri.package "niri"} msg action power-off-monitors' resume '${lib.getExe' config.programs.niri.package "niri"} msg action power-on-monitors' timeout 900 '${lib.getExe' pkgs.systemd "systemctl"} suspend' before-sleep '${lib.getExe' config.programs.niri.package "niri"} msg action power-on-monitors' after-resume '${lib.getExe' config.programs.niri.package "niri"} msg action power-on-monitors'"

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
  };

  # Allow the greeter's swayidle to suspend on idle. greetd's greeter session
  # isn't reliably seen as "active" by logind, so the active-session default
  # for org.freedesktop.login1.suspend may not apply — grant it explicitly.
  # The module runs the greeter as its own "dms-greeter" user, not "greeter".
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.login1.suspend" &&
          subject.user == "dms-greeter") {
        return polkit.Result.YES;
      }
    });
  '';

  # --- Notification Daemon (Mako) ---
  # Niri doesn't come with a notification daemon, Mako is recommended
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    playerctl
    mako

    jq # dms-greeter reads the cursor theme with it, off the pam_env PATH
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
    # gtk is the default backend, but it doesn't implement ScreenCast/Screenshot,
    # so route those to the gnome backend (needed for Discord/OBS screen sharing).
    config.common = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };
}
