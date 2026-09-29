{ pkgs, inputs, config, lib, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    package = pkgs.noctalia;
    systemd.enable = true;
    settings = {
      shell = {
        launch_apps_as_systemd_services = true;
        avatar_path = "${../../../assets/gustav-avatar.jpg}";
        time_format = "{:%-I:%M %p}";
        date_format = "%a, %b %-d";
        screenshot.annotate = true;
      };
      wallpaper.enabled = true;
      bar.default = {
        position = "bottom";
        auto_hide = false;
        smart_auto_hide = true;
        reserve_space = false;
        background_opacity = 0.0;
        shadow = false;
        widget_spacing = 10;
        start = [ "launcher" "wallpaper" "workspaces" "media" ];
        center = [ "clock" "clock-weather-gap" "weather" ];
        end = [
          "tray"
          "notifications"
          "clipboard"
          "brightness"
          "volume"
          "cpu"
          "memory"
          "battery"
          "control-center"
          "session"
        ];
      };
      widget = {
        media.hide_when_no_media = true;
        clock.format = "{:%-I:%M %p} · {:%a, %b %-d}";
        clock-weather-gap = {
          type = "spacer";
          length = 12;
        };
        control-center = {
          capsule = true;
          capsule_padding = 24;
        };
        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
        };
        memory = {
          type = "sysmon";
          stat = "ram_pct";
        };
      };
      calendar = {
        event_time_format = "%-I:%M %p";
        event_date_format = "%a, %b %-d";
      };
      location = {
        address = "Sunnyvale, CA";
        # Noctalia centers each one-hour Night Light fade on these times.
        # Start warming at 23:00 and start returning to daylight at 08:00.
        custom_schedule = true;
        sunset = "23:30";
        sunrise = "08:30";
      };
      nightlight.enabled = true;
      weather = {
        enabled = true;
        unit = "imperial";
      };
    };
  };

  programs.niri.settings = {
    binds = {
      "Mod+Space".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "panel-toggle" "launcher";
      "Mod+Shift+Space".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "panel-toggle" "control-center";
      "Mod+Ctrl+Comma".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "settings-toggle";
      "Mod+Alt+L".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "session" "lock";
      "Mod+S".action = lib.mkForce (config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "screenshot-region");
      "Print".action = lib.mkForce (config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "screenshot-region");
      "Ctrl+Print".action = lib.mkForce (config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "screenshot-region");
      "Alt+Print".action = lib.mkForce (config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "screenshot-region");
    };
    window-rules = [
      {
        matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
        open-floating = true;
      }
    ];
  };
}
