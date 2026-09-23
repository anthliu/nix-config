{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/stylix.nix
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/hardware/swap.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
  ];

  networking.hostName = "callisto";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [ pkgs.brightnessctl ];
  services.fwupd.enable = true;

  # DMS reads laptop batteries through UPower. Its NixOS module enables the
  # power-profiles daemon but currently does not enable UPower itself.
  services.upower.enable = true;

  # Callisto is used with the monitor setups from both desktop hosts. Keep the
  # greeter topology alongside the logged-in session settings in home.nix.
  services.displayManager.dms-greeter = {
    configHome = "/home/anthliu";
    compositor.customConfig = lib.mkAfter ''
      output "Dell Inc. AW3423DWF BDRK2S3" {
          mode "3440x1440@164.900"
          scale 1.0
          position x=0 y=0
      }

      output "Samsung Electric Company Odyssey G81SF HNBYA00490" {
          mode "3840x2160@239.996"
          scale 1.25
          position x=3440 y=0
      }

      output "Dell Inc. DELL P2723DE 8VCSX34" {
          mode "2560x1440@59.951"
          scale 1.0
          position x=0 y=0
      }
    '';
  };

  # The external keyboard already swaps these keys in its own firmware. Apply
  # the remap only to the ThinkPad's built-in AT keyboard to avoid swapping it
  # a second time on external keyboards.
  services.keyd = {
    enable = true;
    keyboards.thinkpad = {
      ids = [ "0001:0001" ];
      settings.main = {
        capslock = "leftcontrol";
        leftcontrol = "capslock";
      };
    };
  };

  # The generic ThinkPad module defaults to the older IBM device name, so its
  # TrackPoint tuning service otherwise never matches this laptop's hardware.
  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";

  users.users.anthliu.extraGroups = [
    "networkmanager"
    "wheel"
    "audio"
    "video"
  ];
  home-manager.users.anthliu = import ./home.nix;

  system.stateVersion = "25.11";
}
