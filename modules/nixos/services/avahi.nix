{ config, pkgs, ... }:

{
  # Enable the Avahi daemon for mDNS/DNS-SD
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
