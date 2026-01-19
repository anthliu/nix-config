{ pkgs, lib, ... }:

let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    # Wait for the server to be ready and have devices
    # We try a few times in case the server is slow to find the HID devices
    for i in 1 2 3 4 5; do
      ${pkgs.openrgb}/bin/openrgb --mode static --color 000000 && exit 0
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
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [
    pkgs.openrgb
    no-rgb
  ];
}
