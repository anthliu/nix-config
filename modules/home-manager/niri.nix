{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.niri.homeModules.niri ];

  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb = {
            # layout = "us,ru";
            # options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
        mouse = {
          # natural-scroll = true;
        };
      };

      outputs = {
        "Dell Inc. AW3423DWF BDRK2S3" = {
          mode = {
            width = 3440;
            height = 1440;
            refresh = 164.900;
          };
          scale = 1.0;
          # transform = "normal";
          position = {
            x = 0;
            y = 0;
          };
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 0.5; }
          { proportion = 2.0 / 3.0; }
        ];
        default-column-width = { proportion = 0.5; };
        focus-ring = {
          width = 3;
          active.color = "#f3f3f360";
          inactive.color = "#505050";
        };
        border = {
          enable = false;
        };
        shadow = {
          # on = true;
          softness = 30;
          spread = 5;
          offset = { x = 0; y = 5; };
          color = "#0007";
        };
      };

      spawn-at-startup = [
        # { command = [ "waybar" ]; }
        # { command = [ "swaybg" "-i" "/path/to/image.jpg" ]; }
      ];

      window-rules = [
        {
          geometry-corner-radius = let r = 12.0; in {
            top-left = r;
            top-right = r;
            bottom-right = r;
            bottom-left = r;
          };
          clip-to-geometry = true;
        }
        {
          matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
          default-column-width = {};
        }
        {
          matches = [ 
            { app-id = "firefox$"; title = "^Picture-in-Picture$"; } 
          ];
          open-floating = true;
        }
      ];

      binds = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";
      in {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+T".action = spawn "alacritty";
        "Mod+D".action = spawn "fuzzel";
        "Super+Alt+L".action = spawn "swaylock";

        "Super+Alt+S".action = spawn-sh "pkill orca || exec orca";

        "XF86AudioRaiseVolume".action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
        "XF86AudioLowerVolume".action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        "XF86AudioMute".action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute".action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        "XF86AudioPlay".action = spawn-sh "playerctl play-pause";
        "XF86AudioStop".action = spawn-sh "playerctl stop";
        "XF86AudioPrev".action = spawn-sh "playerctl previous";
        "XF86AudioNext".action = spawn-sh "playerctl next";

        "XF86MonBrightnessUp".action = spawn "brightnessctl" "--class=backlight" "set" "+10%";
        "XF86MonBrightnessDown".action = spawn "brightnessctl" "--class=backlight" "set" "10%-";

        "Mod+O".action = toggle-overview;
        "Mod+Q".action = close-window;

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;

        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Down".action = move-window-down;
        "Mod+Ctrl+Up".action = move-window-up;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+J".action = move-window-down;
        "Mod+Ctrl+K".action = move-window-up;
        "Mod+Ctrl+L".action = move-column-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Shift+H".action = focus-monitor-left;
        "Mod+Shift+J".action = focus-monitor-down;
        "Mod+Shift+K".action = focus-monitor-up;
        "Mod+Shift+L".action = focus-monitor-right;

        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
        
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;

        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;

        "Mod+WheelScrollDown".action = focus-workspace-down;
        "Mod+WheelScrollUp".action = focus-workspace-up;
        "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
        "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
        
        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;
        "Mod+Ctrl+WheelScrollRight".action = move-column-right;
        "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
        "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
        "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+Ctrl+1".action = { move-column-to-workspace = [ 1 ]; };
        "Mod+Ctrl+2".action = { move-column-to-workspace = [ 2 ]; };
        "Mod+Ctrl+3".action = { move-column-to-workspace = [ 3 ]; };
        "Mod+Ctrl+4".action = { move-column-to-workspace = [ 4 ]; };
        "Mod+Ctrl+5".action = { move-column-to-workspace = [ 5 ]; };
        "Mod+Ctrl+6".action = { move-column-to-workspace = [ 6 ]; };
        "Mod+Ctrl+7".action = { move-column-to-workspace = [ 7 ]; };
        "Mod+Ctrl+8".action = { move-column-to-workspace = [ 8 ]; };
        "Mod+Ctrl+9".action = { move-column-to-workspace = [ 9 ]; };

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
        "Mod+W".action = toggle-column-tabbed-display;

        "Print".action = spawn "niri" "msg" "action" "screenshot";
        "Ctrl+Print".action = spawn "niri" "msg" "action" "screenshot";
        "Alt+Print".action = spawn "niri" "msg" "action" "screenshot";

        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;
        "Mod+Shift+P".action = power-off-monitors;
      };
    };
  };
}
