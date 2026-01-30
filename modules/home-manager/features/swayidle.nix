{ pkgs, ... }:

let
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
in
{
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
