{
  config,
  pkgs,
  ...
}:

{
  programs.fuzzel = {
    enable = true;
    settings.main."dpi-aware" = "no";
  };

  # Set idle display commands for swayidle.
  # Use the same patched package as the compositor for its IPC commands.
  custom.idle = {
    displayOffCommand = "${config.wayland.windowManager.niri.package}/bin/niri msg action power-off-monitors";
    displayOnCommand = "${config.wayland.windowManager.niri.package}/bin/niri msg action power-on-monitors";
  };

  wayland.windowManager.niri = {
    enable = true;
    package = import ../../../packages/niri-patched.nix { inherit pkgs; };
    settings = {
      # Run Electron/Chromium apps natively on Wayland (matches the mango session)
      # so screen sharing goes through the PipeWire portal instead of XWayland.
      environment = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      input = {
        keyboard = {
          xkb = {
            # layout = "us,ru";
            # options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
          };
        };
        touchpad = {
          tap = { };
          natural-scroll = { };
        };
        mouse = {
          # natural-scroll = true;
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths._children = [
          { proportion = 0.4; }
          { proportion = 0.5; }
          { proportion = 0.6; }
        ];
        default-column-width = {
          proportion = 0.4;
        };
        focus-ring = {
          width = 4;
          active-color = "hsla(0, 0%, 100%, 0.5)";
          inactive-color = "hsla(0, 0%, 100%, 0.5)";
        };
        border = {
          off = { };
        };
        shadow = {
          # on = true;
          softness = 30;
          spread = 5;
          offset._props = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };
      };

      gestures = {
        hot-corners.off = { };
      };

      _children = [
        {
          window-rule = {
            geometry-corner-radius = [
              12.0
              12.0
              12.0
              12.0
            ];
            clip-to-geometry = true;
          };
        }
        {
          window-rule = {
            match._props.app-id = "^org\\.wezfurlong\\.wezterm$";
            default-column-width = { };
          };
        }
        {
          window-rule = {
            _children = [
              { match._props.app-id = "^mpv$"; }
              { match._props.app-id = "^umpv$"; }
              { match._props.app-id = "^vlc$"; }
            ];
            default-column-width = { };
          };
        }
        {
          window-rule = {
            match._props = {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            };
            open-floating = true;
          };
        }
      ];

      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = { };

        "Mod+T".spawn = [ "foot" ];
        "Mod+D".spawn = [ "fuzzel" ];
        "Mod+E".spawn = [ "thunar" ];

        "Super+Alt+S".spawn-sh = [ "pkill orca || exec orca" ];

        "XF86AudioRaiseVolume".spawn-sh = [ "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0" ];
        "XF86AudioLowerVolume".spawn-sh = [ "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-" ];
        "XF86AudioMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];
        "XF86AudioMicMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ];

        "XF86AudioPlay".spawn-sh = [ "playerctl play-pause" ];
        "XF86AudioStop".spawn-sh = [ "playerctl stop" ];
        "XF86AudioPrev".spawn-sh = [ "playerctl previous" ];
        "XF86AudioNext".spawn-sh = [ "playerctl next" ];

        "XF86MonBrightnessUp".spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "+10%"
        ];
        "XF86MonBrightnessDown".spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "10%-"
        ];

        "Mod+O".toggle-overview = { };
        "Mod+Q".close-window = { };

        "Mod+Left".focus-column-left = { };
        "Mod+Down".focus-window-down = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Right".focus-column-right = { };
        "Mod+H".focus-column-left = { };
        "Mod+J".focus-window-down = { };
        "Mod+K".focus-window-up = { };
        "Mod+L".focus-column-right = { };

        "Mod+Ctrl+Left".move-column-left = { };
        "Mod+Ctrl+Down".move-window-down = { };
        "Mod+Ctrl+Up".move-window-up = { };
        "Mod+Ctrl+Right".move-column-right = { };
        "Mod+Ctrl+H".move-column-left = { };
        "Mod+Ctrl+J".move-window-down = { };
        "Mod+Ctrl+K".move-window-up = { };
        "Mod+Ctrl+L".move-column-right = { };

        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };
        "Mod+Ctrl+Home".move-column-to-first = { };
        "Mod+Ctrl+End".move-column-to-last = { };

        "Mod+Shift+Left".focus-monitor-left = { };
        "Mod+Shift+Down".focus-monitor-down = { };
        "Mod+Shift+Up".focus-monitor-up = { };
        "Mod+Shift+Right".focus-monitor-right = { };
        "Mod+Shift+H".focus-monitor-left = { };
        "Mod+Shift+J".focus-monitor-down = { };
        "Mod+Shift+K".focus-monitor-up = { };
        "Mod+Shift+L".focus-monitor-right = { };

        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

        "Mod+Page_Down".focus-workspace-down = { };
        "Mod+Page_Up".focus-workspace-up = { };
        "Mod+U".focus-workspace-down = { };
        "Mod+I".focus-workspace-up = { };
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };
        "Mod+Ctrl+U".move-column-to-workspace-down = { };
        "Mod+Ctrl+I".move-column-to-workspace-up = { };

        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Shift+U".move-workspace-down = { };
        "Mod+Shift+I".move-workspace-up = { };

        "Mod+WheelScrollDown".focus-workspace-down = { };
        "Mod+WheelScrollUp".focus-workspace-up = { };
        "Mod+Ctrl+WheelScrollDown".move-column-to-workspace-down = { };
        "Mod+Ctrl+WheelScrollUp".move-column-to-workspace-up = { };

        "Mod+WheelScrollRight".focus-column-right = { };
        "Mod+WheelScrollLeft".focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".move-column-left = { };

        "Mod+Shift+WheelScrollDown".focus-column-right = { };
        "Mod+Shift+WheelScrollUp".focus-column-left = { };
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };

        "Mod+1".focus-workspace = [ 1 ];
        "Mod+2".focus-workspace = [ 2 ];
        "Mod+3".focus-workspace = [ 3 ];
        "Mod+4".focus-workspace = [ 4 ];
        "Mod+5".focus-workspace = [ 5 ];
        "Mod+6".focus-workspace = [ 6 ];
        "Mod+7".focus-workspace = [ 7 ];
        "Mod+8".focus-workspace = [ 8 ];
        "Mod+9".focus-workspace = [ 9 ];
        "Mod+Ctrl+1" = {
          move-column-to-workspace = [ 1 ];
        };
        "Mod+Ctrl+2" = {
          move-column-to-workspace = [ 2 ];
        };
        "Mod+Ctrl+3" = {
          move-column-to-workspace = [ 3 ];
        };
        "Mod+Ctrl+4" = {
          move-column-to-workspace = [ 4 ];
        };
        "Mod+Ctrl+5" = {
          move-column-to-workspace = [ 5 ];
        };
        "Mod+Ctrl+6" = {
          move-column-to-workspace = [ 6 ];
        };
        "Mod+Ctrl+7" = {
          move-column-to-workspace = [ 7 ];
        };
        "Mod+Ctrl+8" = {
          move-column-to-workspace = [ 8 ];
        };
        "Mod+Ctrl+9" = {
          move-column-to-workspace = [ 9 ];
        };

        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };

        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-window-height = { };
        "Mod+Ctrl+R".reset-window-height = { };
        "Mod+F".maximize-column = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+Ctrl+F".expand-column-to-available-width = { };

        "Mod+C".center-column = { };
        "Mod+Ctrl+C".center-visible-columns = { };

        "Mod+Minus".set-column-width = [ "-10%" ];
        "Mod+Equal".set-column-width = [ "+10%" ];
        "Mod+Shift+Minus".set-window-height = [ "-10%" ];
        "Mod+Shift+Equal".set-window-height = [ "+10%" ];

        "Mod+V".toggle-window-floating = { };
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };
        "Mod+W".toggle-column-tabbed-display = { };

        "Mod+S".spawn = [
          "niri"
          "msg"
          "action"
          "screenshot"
        ];
        "Print".spawn = [
          "niri"
          "msg"
          "action"
          "screenshot"
        ];
        "Ctrl+Print".spawn = [
          "niri"
          "msg"
          "action"
          "screenshot"
        ];
        "Alt+Print".spawn = [
          "niri"
          "msg"
          "action"
          "screenshot"
        ];

        "Mod+Shift+E".quit = { };
        "Ctrl+Alt+Delete".quit = { };
        "Mod+Shift+P".power-off-monitors = { };
      };
    };
  };
}
