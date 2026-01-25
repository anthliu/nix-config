{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    lact
  ];

  systemd.services.lactd = {
    description = "GPU Control Daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    wantedBy = ["multi-user.target"];
  };
}
