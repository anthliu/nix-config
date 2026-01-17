{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/ssh.nix
  ];

  # Home Manager needs to know who you are
  home.username = "anthliu";
  home.homeDirectory = "/home/anthliu";

  # Install user-specific packages here
  home.packages = with pkgs; [
    ripgrep
    jq
    htop
    fzf
    antigravity
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # State version for Home Manager (similar to NixOS system.stateVersion)
  home.stateVersion = "24.11"; 
} 
