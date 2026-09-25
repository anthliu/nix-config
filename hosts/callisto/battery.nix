{ pkgs, ... }:

let
  batteryPath = "/sys/class/power_supply/BAT0";

  battery-charge-mode = pkgs.writeShellApplication {
    name = "battery-charge-mode";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      battery=${batteryPath}
      start="$battery/charge_control_start_threshold"
      end="$battery/charge_control_end_threshold"

      if [[ ! -e "$start" || ! -e "$end" ]]; then
        echo "Battery charge thresholds are not available on this machine." >&2
        exit 1
      fi

      mode="''${1:-status}"

      if [[ "$mode" == "status" ]]; then
        printf 'start: %s%%\nend:   %s%%\n' "$(<"$start")" "$(<"$end")"
        exit 0
      fi

      if [[ "$(id -u)" != 0 ]]; then
        exec ${pkgs.polkit}/bin/pkexec "$0" "$mode"
      fi

      case "$mode" in
        care)
          # Lower the start threshold before the end threshold so the values
          # remain valid when switching from the 99/100 full-charge mode.
          echo 75 > "$start"
          echo 90 > "$end"
          ;;
        full)
          # Raise the end threshold first. A 99% start threshold makes this an
          # immediate one-off full charge instead of waiting to fall below 75%.
          echo 100 > "$end"
          echo 99 > "$start"
          ;;
        *)
          echo "Usage: battery-charge-mode {care|full|status}" >&2
          exit 2
          ;;
      esac

      printf 'start: %s%%\nend:   %s%%\n' "$(<"$start")" "$(<"$end")"
    '';
  };
in
{
  environment.systemPackages = [ battery-charge-mode ];

  # Avoid keeping the battery at 100% while Callisto spends long periods on AC.
  # The helper also provides an authenticated full-charge mode for travel.
  systemd.services.battery-charge-thresholds = {
    description = "Set ThinkPad battery charge thresholds";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    unitConfig.ConditionPathExists = "${batteryPath}/charge_control_end_threshold";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${battery-charge-mode}/bin/battery-charge-mode care
    '';
  };
}
