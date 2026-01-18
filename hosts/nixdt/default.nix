{ pkgs, inputs,	... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/niri.nix
    inputs.dms.nixosModules.default
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/nix-ld.nix


    inputs.home-manager.nixosModules.default
    
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.gigabyte-b650
    ./usb-wakeup.nix
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
      sort-key 0_windows
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

  # --- Home Manager Configuration ---
  home-manager = {
    # 1. Force Home Manager to use the System's config (including allowUnfree)
    useGlobalPkgs = true;
    
    # 2. Install packages to /etc/profiles instead of ~/.nix-profile
    # (Recommended for better integration, but optional)
    useUserPackages = false;

    # Also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "anthliu" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  # --- State Version ---
  system.stateVersion = "25.11";
}
