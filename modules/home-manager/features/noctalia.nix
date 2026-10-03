{ pkgs, inputs, config, lib, ... }:

let
  # Noctalia's widget layouts match connector names, not Niri's EDID selectors.
  # Cover laptop panels and desktop/dock ports; disconnected outputs are ignored.
  lockOutputs = [ "eDP-1" "eDP-2" ]
    ++ lib.genList (n: "DP-${toString (n + 1)}") 8
    ++ lib.genList (n: "HDMI-A-${toString (n + 1)}") 2;
  lockWidget = output: extra: {
    inherit output;
    # Native placement scales centers, but not widget boxes. Keep controls grouped
    # and use a smaller clock on internal panels than on desktop/dock outputs.
    placement_width = 1920.0;
    placement_height = 1080.0;
    cx = 960.0;
  } // extra;
  lockWidgets = lib.foldl' (widgets: output:
    let laptop = lib.hasPrefix "eDP-" output;
    in widgets // {
      "stacked-clock@${output}" = lockWidget output {
        type = "clock";
        cy = if laptop then 400.0 else 430.0;
        box_width = if laptop then 400.0 else 520.0;
        box_height = if laptop then 370.0 else 440.0;
        settings = {
          clock_style = "digital";
          font_family = "Roboto Medium";
          format = "{:%I}\n{:%M}";
          center_text = true;
          circle = false;
          background = false;
          color = "on_surface";
          shadow = false;
        };
      };
      "lock-date@${output}" = lockWidget output {
        type = "clock";
        cy = if laptop then 610.0 else 630.0;
        box_width = 380.0;
        box_height = if laptop then 28.0 else 32.0;
        settings = {
          format = "{:%a, %b %-d}";
          shadow = false;
          center_text = true;
          background = false;
          color = "on_surface";
        };
      };
      "lockscreen-login-box@${output}" = lockWidget output {
        type = "login_box";
        cy = if laptop then 710.0 else 720.0;
        box_width = if laptop then 400.0 else 480.0;
        box_height = 70.0;
        settings = {
          layout = "compact";
          # Also controls fingerprint prompts and authentication progress.
          show_unlock_hint = true;
          show_login_button = false;
          show_keyboard_layout = false;
          show_session_buttons = false;
          show_media = false; # Provided by the separate lock-media widget below.
          show_weather = false;
          show_caps_lock = true;
          background_opacity = 0.0;
          input_opacity = 0.75;
          input_radius = 12.0;
          center_password_text = true;
        };
      };
      "lock-media@${output}" = lockWidget output {
        type = "media_player";
        cy = 870.0;
        box_width = if laptop then 400.0 else 480.0;
        box_height = if laptop then 96.0 else 110.0;
        settings = {
          layout = "horizontal";
          hide_when_no_media = true;
          background = false;
          shadow = false;
          color = "on_surface";
        };
      };
  }) { } lockOutputs;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  # Clock widgets request Bold internally. Select the actual Medium face without
  # artificial emboldening, and keep equal-width digits scoped to this clock font.
  fonts.fontconfig.configFile.noctalia-clock = {
    enable = true;
    priority = 60;
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <test name="family" compare="eq" qual="any">
            <string>Roboto Medium</string>
          </test>
          <edit name="weight" mode="assign"><const>medium</const></edit>
          <edit name="fontfeatures" mode="append"><string>tnum=1</string></edit>
          <edit name="embolden" mode="assign"><bool>false</bool></edit>
        </match>
      </fontconfig>
    '';
  };

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
      lockscreen = {
        blur_intensity = 0.1;
        tint_intensity = 0.25;
      };
      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = lib.concatMap (output: [
          "stacked-clock@${output}"
          "lock-date@${output}"
          "lockscreen-login-box@${output}"
          "lock-media@${output}"
        ]) lockOutputs;
        widget = lockWidgets;
      };
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
