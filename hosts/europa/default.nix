{ pkgs, inputs, ... }:

{
  imports = [
    # Generated on the machine itself by `nixos-generate-config`; this file is
    # the only part of the host that cannot be written ahead of the install.
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop/niri.nix
    inputs.dms.nixosModules.default
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/services/stylix.nix
    ../../modules/nixos/services/remote-access.nix
    ../../modules/nixos/hardware/swap.nix
    inputs.stylix.nixosModules.stylix

    inputs.home-manager.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  # --- Machine Specifics ---
  networking.hostName = "europa";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- User Config ---
  users.users.anthliu = {
    isNormalUser = true;
    description = "Anthony Liu";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    # Don't forget to set password with `passwd`
  };

  # --- Home Manager Configuration ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      "anthliu" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  # --- State Version ---
  # Tracks the release this host's on-disk state was first created under, and
  # never changes afterwards. It follows the nixpkgs this flake is pinned to
  # (26.11), not the older release the installer ISO happens to carry.
  system.stateVersion = "26.11";
}
