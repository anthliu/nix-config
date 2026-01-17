{ pkgs, ... }: 

{
  # --- Core Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.config.allowUnfree = true;

  # --- Locale & Time ---
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # --- Essential Packages ---
  # Every machine you own should have these
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
  ];

  environment.variables.EDITOR = "vim";
}
