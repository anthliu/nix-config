{ pkgs, ... }:

{
  imports = [
    # 1. Hardware Scan (Machine specific)
    ./hardware-configuration.nix
    
    # 2. Shared Modules (Relative paths)
    ../../modules/nixos/base.nix
    ../../modules/nixos/gnome.nix
  ];

  # --- Machine Specifics ---
  networking.hostName = "nixdt";
  networking.networkmanager.enable = true;

  # Bootloader (Specific to this dual-boot setup)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows
      efi /EFI/edk2-uefi-shell/shell.efi
      options -nointerrupt -noconsolein -noconsoleout "FS2:\EFI\Microsoft\Boot\Bootmgfw.efi"
    '';
  };

  # --- User Config ---
  # Users are often specific to the machine (e.g., servers vs laptops)
  users.users.anthliu = {
    isNormalUser = true;
    description = "Anthony Liu";
    extraGroups = [ "networkmanager" "wheel" ];
    # Don't forget to set password with `passwd`
  };

  # --- State Version ---
  system.stateVersion = "25.11";
}
