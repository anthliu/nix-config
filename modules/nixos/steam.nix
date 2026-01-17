{ pkgs, lib, ... }: 

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  
  # Gamemode - optimises system performance for games
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud # Performance overlay
    protonup-qt # Proton version manager
  ];
}
