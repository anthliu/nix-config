{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true; # Open ports 8096 (HTTP) and 8920 (HTTPS) for local access
  };

  users.users.jellyfin = {
    extraGroups = [ "users" "render" "video" ];
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
