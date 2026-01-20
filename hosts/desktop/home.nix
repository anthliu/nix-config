{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/profiles/desktop.nix
    ../../modules/nixos/services/stylix.nix
  ];

  # Home Manager needs to know who you are
  home.username = "anthliu";
  home.homeDirectory = "/home/anthliu";

  # Install user-specific packages here
  home.packages = with pkgs; [
    # Explicitly install Home Manager CLI
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # State version for Home Manager (similar to NixOS system.stateVersion)
  home.stateVersion = "25.11"; 
} 
