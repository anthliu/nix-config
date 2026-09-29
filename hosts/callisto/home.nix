{ pkgs, lib, ... }:

let
  batteryPowerProfile = pkgs.writeShellScript "noctalia-battery-power-profile" ''
    set -euo pipefail

    percentage="''${NOCTALIA_BATTERY_PERCENT:-}"
    [[ "$percentage" =~ ^[0-9]+$ ]] || exit 0

    state_file="''${XDG_RUNTIME_DIR:?}/noctalia-low-battery-power-saver"
    if (( 10#$percentage <= 20 )); then
      [[ "''${NOCTALIA_BATTERY_STATE:-}" == "discharging" && ! -e "$state_file" ]] || exit 0

      ${pkgs.noctalia}/bin/noctalia msg power-set power-saver
      ${pkgs.noctalia}/bin/noctalia msg notification-show "Battery low" "Battery at $percentage%. Power saver enabled."
      ${pkgs.coreutils}/bin/touch "$state_file"
    elif (( 10#$percentage >= 25 )) && [[ -e "$state_file" ]]; then
      ${pkgs.noctalia}/bin/noctalia msg power-set balanced
      ${pkgs.noctalia}/bin/noctalia msg notification-show "Battery recovered" "Battery at $percentage%. Balanced profile enabled."
      ${pkgs.coreutils}/bin/rm -f "$state_file"
    fi
  '';
in
{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/graphical.nix
    ../../modules/home-manager/features/local-ai.nix
    ../../modules/home-manager/features/niri.nix
    ../../modules/home-manager/features/noctalia.nix
    ../../modules/home-manager/features/qmk.nix
    ../../modules/home-manager/features/swayidle.nix
    ../../modules/shared/stylix.nix
    ./theme.nix
  ];

  programs.noctalia.settings.shell.avatar_path =
    lib.mkForce "${../../assets/sheba-avatar.jpg}";

  programs.noctalia.settings.bar.default.monitor.laptop = {
    match = "InfoVision Optoelectronics";
    scale = 1.15;
  };

  programs.noctalia.settings.hooks.battery_percentage_changed = "${batteryPowerProfile}";

  # Keep the explicit lock-before-suspend sequence used by this laptop's idle
  # service until its suspend and fingerprint path is tested with Noctalia.
  custom.idle.extraBeforeSleepCommand = ''
    ${pkgs.noctalia}/bin/noctalia msg session lock
    ${pkgs.coreutils}/bin/sleep 1
  '';

  # Slow only the built-in touchpad on Callisto. Keeping this host-local avoids
  # changing touchpad behavior on the desktop hosts or any mouse-wheel events.
  programs.niri.settings.input.touchpad.scroll-factor = 0.5;

  programs.niri.settings.outputs = {
    # Keep the laptop on the left. Niri automatically places connected external
    # displays to the right, even when the docking setup changes.
    "InfoVision Optoelectronics (Kunshan) Co.,Ltd China 0x057D Unknown" = {
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };

    "Dell Inc. AW3423DWF BDRK2S3" = {
      mode = {
        width = 3440;
        height = 1440;
        refresh = 164.900;
      };
      scale = 1.0;
    };

    "Samsung Electric Company Odyssey G81SF HNBYA00490" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 239.996;
      };
      scale = 1.25;
    };

    "Dell Inc. DELL P2723DE 8VCSX34" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 59.951;
      };
      scale = 1.0;
    };
  };

  home.stateVersion = "25.11";
}
