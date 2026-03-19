{ pkgs, lib, ... }:

let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    # Attempt to turn off devices using both common 'off' methods.
    # 1. 'Off' mode (used by EVGA 3090 and others)
    # 2. 'Static' mode with black color (used by Gigabyte and others)
    # the server handles device detection, so we connect instead of using --noautoconnect
    ${pkgs.openrgb}/bin/openrgb --mode Off >/dev/null 2>&1 || true
    ${pkgs.openrgb}/bin/openrgb --mode Static --color 000000 >/dev/null 2>&1 || true

    # Only exit successfully if the motherboard and GPU were actually found and commanded.
    # Otherwise, systemd will retry based on Restart=on-failure.
    if ${pkgs.openrgb}/bin/openrgb --list-devices | grep -q "B650 GAMING X AX V2" && \
       ${pkgs.openrgb}/bin/openrgb --list-devices | grep -i -q "EVGA"; then
      exit 0
    fi
    exit 1
  '';
in
{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb;
  };

  # Required for OpenRGB to access devices
  services.udev.packages = [ pkgs.openrgb ];
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  hardware.i2c.enable = true;

  # Force a scan before the server starts to help it find the Gigabyte HID controller
  systemd.services.openrgb.serviceConfig.ExecStartPre = [
    "-${pkgs.openrgb}/bin/openrgb --noautoconnect --scan"
  ];

  systemd.services.no-rgb = {
    description = "Turn off all RGB devices";
    after = [ "openrgb.service" ];
    requires = [ "openrgb.service" ];
    serviceConfig = {
      ExecStart = "${no-rgb}/bin/no-rgb";
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "1s";
    };
    wantedBy = [ "multi-user.target" "post-resume.target" ];
  };

  environment.systemPackages = [
    pkgs.openrgb
    no-rgb
  ];
}
