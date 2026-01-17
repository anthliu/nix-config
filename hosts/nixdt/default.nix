{ pkgs, inputs,	... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/gnome.nix
    ../../modules/nixos/nvidia.nix

    inputs.home-manager.nixosModules.default
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

  # --- Home Manager Configuration ---
  home-manager = {
    # 1. Force Home Manager to use the System's config (including allowUnfree)
    useGlobalPkgs = true;
    
    # 2. Install packages to /etc/profiles instead of ~/.nix-profile
    # (Recommended for better integration, but optional)
    useUserPackages = true;

    # Also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "anthliu" = import ./home.nix;
    };
  };

  # --- State Version ---
  system.stateVersion = "25.11";
}
