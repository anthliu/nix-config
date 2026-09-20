{ inputs, lib, ... }:

{
  imports = [
    # Generated on the machine itself by `nixos-generate-config`; this file is
    # the only part of the host that cannot be written ahead of the install.
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/stylix.nix
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

  services.displayManager.dms-greeter = {
    configHome = "/home/anthliu";
    compositor.customConfig = lib.mkAfter ''
      output "Dell Inc. DELL P2723DE 8VCSX34" {
          mode "2560x1440@59.951"
          scale 1.0
          position x=0 y=0
      }
    '';
  };

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
