{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/790b2f2d-cdf0-4c09-b786-b7af4308cc72";
    fsType = "btrfs";
    options = [ "noatime" "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5CBC-90D3";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
