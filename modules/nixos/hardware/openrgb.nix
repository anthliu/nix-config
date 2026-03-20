{ pkgs, lib, ... }:

let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    # Give the hardware a moment to wake up
    sleep 3
    for i in 1 2 3 4 5; do
      # Attempt to turn off devices
      ${pkgs.openrgb}/bin/openrgb --mode Off >/dev/null 2>&1
      ${pkgs.openrgb}/bin/openrgb --mode Static --color 000000 >/dev/null 2>&1
      
      # Check if both motherboard and GPU are detected AND the command worked
      if ${pkgs.openrgb}/bin/openrgb --list-devices | grep -q "B650 GAMING X AX V2" && \
         ${pkgs.openrgb}/bin/openrgb --list-devices | grep -i -q "EVGA"; then
        exit 0
      fi
      sleep 2
    done
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
