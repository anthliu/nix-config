{ pkgs, ... }:

{
  # --- Boot Loader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Keep custom Windows entry
  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows
      efi /EFI/edk2-uefi-shell/shell.efi
      options -nointerrupt -noconsolein -noconsoleout "FS2:\EFI\Microsoft\Boot\Bootmgfw.efi"
    '';
  };

  # --- Networking ---
  networking.hostName = "nixdt";
  networking.networkmanager.enable = true;

  # --- Time & Locale ---
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # --- Desktop Environment (GNOME) ---
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- User Configuration ---
  users.users.anthliu = {
    isNormalUser = true;
    description = "Anthony Liu"; # Optional: adds full name
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
  ];

  environment.variables.EDITOR = "vim";

  # --- System State ---
  # Do not change this value even if you update NixOS.
  system.stateVersion = "25.11"; 
}
