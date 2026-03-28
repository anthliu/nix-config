{ pkgs, lib, ... }:

let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    # Give the hardware a moment to settle (especially after resume)
    sleep 3
    for i in 1 2 3 4 5; do
      # Directly access devices (--noautoconnect bypasses the server)
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --mode Off >/dev/null 2>&1
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --mode Static --color 000000 >/dev/null 2>&1

      # Check if both motherboard and GPU are detected
      if ${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices 2>/dev/null | grep -q "B650 GAMING X AX V2" && \
         ${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices 2>/dev/null | grep -i -q "EVGA"; then
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

  # On resume from suspend, re-run no-rgb to turn off the lights.
  # --no-block ensures this doesn't delay the resume process.
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl start --no-block no-rgb.service
  '';

  systemd.services.no-rgb = {
    description = "Turn off all RGB devices";
    serviceConfig = {
      ExecStart = "${no-rgb}/bin/no-rgb";
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "1s";
    };
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [
    pkgs.openrgb
    no-rgb
  ];
}
