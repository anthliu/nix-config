{ config, lib, pkgs, ... }:

let
  displayOff = config.custom.idle.displayOffCommand;
  displayOn = config.custom.idle.displayOnCommand;
in
{
  options.custom.idle = {
    displayOffCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to turn off displays for idle management";
      example = "niri msg action power-off-monitors";
    };
    displayOnCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to turn on displays for idle management";
      example = "niri msg action power-on-monitors";
    };
  };

  config = {
    home.packages = [
      (pkgs.writeShellScriptBin "caffeinate" ''
        allow_display_sleep=0
        if [ "$1" == "-s" ] || [ "$1" == "--system" ]; then
          allow_display_sleep=1
          shift
        fi

        STATE_DIR="/run/user/$(id -u)/caffeinate"
        mkdir -p "$STATE_DIR"

        MY_PID="$$"
        if [ "$allow_display_sleep" -eq 1 ]; then
          MY_FILE="$STATE_DIR/$MY_PID"
        else
          MY_FILE="$STATE_DIR/$MY_PID.full"
        fi

        update_state() {
          (
            flock 9
            
            has_full=0
            has_sys=0
            
            # Clean up dead PIDs and count active ones
            for f in "$STATE_DIR"/*; do
              [ -f "$f" ] || continue
              fname=$(basename "$f")
              [ "$fname" = ".lock" ] && continue
              
              # Extract PID
              pid=''${fname%%.*}
              
              # Check if process is alive. If not, and it's not us, remove it.
              if ! kill -0 "$pid" 2>/dev/null && [ "$pid" != "$MY_PID" ]; then
                rm -f "$f"
                continue
              fi
              
              case "$fname" in
                *.full) has_full=1 ;;
                *)      has_sys=1 ;;
              esac
            done

            if [ "$has_full" -eq 1 ]; then
              systemctl --user stop caffeinate-display.service 2>/dev/null
              systemctl --user stop swayidle.service 2>/dev/null
            elif [ "$has_sys" -eq 1 ]; then
              systemctl --user start caffeinate-display.service 2>/dev/null
              systemctl --user stop swayidle.service 2>/dev/null
            else
              systemctl --user stop caffeinate-display.service 2>/dev/null
              systemctl --user start swayidle.service 2>/dev/null
            fi
          ) 9> "$STATE_DIR/.lock"
        }

        cleanup() {
          rm -f "$MY_FILE"
          update_state
        }

        touch "$MY_FILE"
        trap cleanup EXIT
        update_state

        if [ $# -eq 0 ]; then
          echo "Caffeinated. Press Ctrl+C to stop."
          sleep infinity
        else
          "$@"
        fi
      '')
    ];

    services.swayidle = {
      enable = true;

      # "-w" is the module default and must be kept: it makes swayidle wait for
      # each command to finish before continuing, which the resume/power-on
      # ordering depends on. "-d" adds debug logging of every timeout and resume
      # to the journal, so an idle failure (display blanks and never comes back)
      # can be diagnosed from logs instead of reproduced by hand.
      extraArgs = [ "-w" "-d" ];
      # WORKAROUND(nvidia-resume race): nvidia-resume.service takes ~2s after wake
      # to restore the GPU. Logind unfreezes niri before it finishes, causing
      # "Page flip commit failed (Permission denied)" which can corrupt niri's
      # idle notification state. Powering on monitors before sleep ensures the DRM
      # pipeline is active when nvidia-suspend serializes state.
      # See: https://github.com/niri-wm/niri/issues/2139
      # TODO: Remove when niri handles DRM resume errors gracefully (retry page flips).
      events = {
        before-sleep = displayOn;
        after-resume = displayOn;
      };
      timeouts = [
        {
          timeout = 300; # 5 minutes
          command = displayOff;
          resumeCommand = displayOn;
        }
        {
          timeout = 900; # 15 minutes
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

    systemd.user.services.caffeinate-display = {
      Unit = {
        Description = "Caffeinate display-only idle manager";
      };
      Service = {
        # WORKAROUND(nvidia-resume race): Same as above.
        ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${displayOff}' resume '${displayOn}' before-sleep '${displayOn}' after-resume '${displayOn}'";
      };
    };
  };
}
