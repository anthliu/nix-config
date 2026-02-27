{ pkgs, ... }:

let
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "caffeinate" ''
      allow_display_sleep=0
      if [ "$1" == "-s" ] || [ "$1" == "--system" ]; then
        allow_display_sleep=1
        shift
      fi

      STATE_DIR="/run/user/$(id -u)/caffeinate"
      mkdir -p "$STATE_DIR"

      if [ "$allow_display_sleep" -eq 1 ]; then
        MY_FILE="$STATE_DIR/$$"
      else
        MY_FILE="$STATE_DIR/$$.full"
      fi

      update_state() {
        (
          flock 9
          
          # Clean up dead PIDs
          for f in "$STATE_DIR"/*; do
            if [ -f "$f" ]; then
              fname=$(basename "$f")
              if [ "$fname" = ".lock" ]; then continue; fi
              # Extract PID (everything before the first dot, if any)
              pid=''${fname%%.*}
              if ! kill -0 "$pid" 2>/dev/null && [ "$pid" != "$$" ]; then
                rm -f "$f"
              fi
            fi
          done

          has_full=0
          has_sys=0
          
          for f in "$STATE_DIR"/*; do
            if [ -f "$f" ]; then
              fname=$(basename "$f")
              if [ "$fname" = ".lock" ]; then continue; fi
              if [[ "$fname" == *.full ]]; then
                has_full=1
              else
                has_sys=1
              fi
            fi
          done

          if [ "$has_full" -eq 1 ]; then
            systemctl --user stop caffeinate-display.service
            systemctl --user stop swayidle.service
          elif [ "$has_sys" -eq 1 ]; then
            systemctl --user start caffeinate-display.service
            systemctl --user stop swayidle.service
          else
            systemctl --user stop caffeinate-display.service
            systemctl --user start swayidle.service
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
    timeouts = [
      {
        timeout = 300; # 5 minutes
        command = display "off";
        resumeCommand = display "on";
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
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${display "off"}' resume '${display "on"}'";
    };
  };
}
