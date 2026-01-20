{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/profiles/dev.nix
  ];

  home.username = "anthliu";
  home.homeDirectory = "/home/anthliu";

  home.packages = with pkgs; [
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.11"; 
}
