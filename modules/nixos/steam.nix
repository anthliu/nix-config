{ pkgs, lib, ... }: 

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs': with pkgs'; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
  
  # Gamemode - optimises system performance for games
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud # Performance overlay
    protonup-qt # Proton version manager
    gamescope-wsi # Required for HDR in Gamescope
  ];
}
