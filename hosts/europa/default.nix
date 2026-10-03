{ inputs, ... }:

{
  imports = [
    # Generated on the machine itself by `nixos-generate-config`; this file is
    # the only part of the host that cannot be written ahead of the install.
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/desktop/niri-noctalia.nix
    ../../modules/nixos/desktop/stylix.nix
    ./theme.nix
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/services/remote-access.nix
    ../../modules/nixos/hardware/swap.nix
    ./swap.nix
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  # --- Machine Specifics ---
  networking.hostName = "europa";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.anthliu.extraGroups = [
    "networkmanager"
    "wheel"
    "audio"
    "video"
  ];
  home-manager.users.anthliu = import ./home.nix;

  # --- State Version ---
  # Compatibility baseline selected when this host was first configured.
  # Do not change it during normal nixpkgs upgrades.
  system.stateVersion = "26.11";
}
