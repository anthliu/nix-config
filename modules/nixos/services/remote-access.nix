{ ... }:

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
    settings.publish = {
      disable-publishing = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
      publish-domain = true;
      publish-hinfo = true;
      publish-workstation = true;
    };
  };
}
