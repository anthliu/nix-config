{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/home-manager/vim.nix
    ../../modules/home-manager/niri.nix
    ../../modules/nixos/stylix.nix
  ];

  # Home Manager needs to know who you are
  home.username = "anthliu";
  home.homeDirectory = "/home/anthliu";

  # Install user-specific packages here
  home.packages = with pkgs; [
    # Explicitly install Home Manager CLI
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
    
    ripgrep
    jq
    htop
    fzf
    antigravity
    uv
    fastfetch
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # State version for Home Manager (similar to NixOS system.stateVersion)
  home.stateVersion = "25.11"; 
} 
