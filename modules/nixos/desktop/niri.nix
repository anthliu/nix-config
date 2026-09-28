{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./dms.nix
    ./niri-base.nix
  ];

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

    # Replaces the launcher's base config, which it skips when given one.
    # Output topology is appended by each host that imports this module.
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

  environment.systemPackages = [ pkgs.jq ]; # dms-greeter reads the cursor theme with it.
}
