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

      was_active=0
      if systemctl --user is-active --quiet swayidle; then
        was_active=1
        systemctl --user stop swayidle
      fi

      temp_swayidle_pid=""
      if [ "$allow_display_sleep" -eq 1 ]; then
        # Run a temporary swayidle that ONLY handles display power
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 '${display "off"}' \
          resume '${display "on"}' &
        temp_swayidle_pid=$!
      fi

      cleanup() {
        if [ -n "$temp_swayidle_pid" ]; then
          kill "$temp_swayidle_pid" 2>/dev/null
        fi
        if [ "$was_active" -eq 1 ]; then
          systemctl --user start swayidle
        fi
      }
      trap cleanup EXIT

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
}
