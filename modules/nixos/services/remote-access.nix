{ pkgs, ... }:

{
  # --- SSH Configuration ---
  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  # --- Avahi (mDNS) Configuration ---
  # Enable the Avahi daemon for mDNS/DNS-SD (host.local discovery)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Register NSS modules so glibc can find them
  system.nssModules = [ pkgs.nssmdns ];
}
