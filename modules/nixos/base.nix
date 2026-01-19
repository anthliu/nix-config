{ pkgs, lib, ... }: 

{
  # --- Core Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.config.allowUnfree = true;

  # --- Locale & Time ---
  time.timeZone = lib.mkDefault "America/Los_Angeles";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
  };

  # --- Essential Packages ---
  # Every machine you own should have these
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    tmux
  ];

  environment.variables.EDITOR = "vim";
}
