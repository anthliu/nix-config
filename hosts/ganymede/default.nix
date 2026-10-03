{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/desktop/niri-noctalia.nix
    ../../modules/nixos/desktop/nvidia-apps.nix
    ../../modules/nixos/desktop/stylix.nix
    ./theme.nix
    ../../modules/nixos/hardware/gputemps.nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/nvidia-rtx3090.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/nix-ld/cuda-native.nix
    ../../modules/nixos/hardware/openrgb.nix
    ../../modules/nixos/hardware/lact.nix
    ../../modules/nixos/hardware/swap.nix
    ./storage.nix
    ../../modules/nixos/services/remote-access.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.gigabyte-b650
    ./usb-wakeup.nix
  ];

  # --- Machine Specifics ---
  networking.hostName = "ganymede";
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

  users.users.anthliu.extraGroups = [
    "networkmanager"
    "wheel"
    "audio"
    "video"
    "i2c"
    "dialout"
  ];
  home-manager.users.anthliu = import ./home.nix;

  # --- State Version ---
  system.stateVersion = "25.11";
}
