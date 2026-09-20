{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/nix-ld/cuda-wsl.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "anthliu";

  users.users.anthliu.extraGroups = [ "wheel" ];

  networking.hostName = "thebe";

  # Publish the GPU libraries Windows injects at /usr/lib/wsl/lib -
  # libcuda.so.1, libnvidia-ml.so.1 and the d3d12 stack - under
  # /run/opengl-driver. They drive the GPU through the paravirtualized /dev/dxg
  # rather than the /dev/nvidia* nodes a native kernel module would create, and
  # are therefore the only build of these libraries that functions in a WSL
  # guest. Leaving this off yields a machine where /dev/dxg is present and
  # working but nothing can find a usable libcuda.
  wsl.useWindowsDriver = true;

  home-manager.users.anthliu = import ./home.nix;

  # Disable systemd-oomd to fix "Device or resource busy" errors in WSL
  # which prevent the user session from starting.
  systemd.oomd.enable = false;

  system.stateVersion = "25.11";
}
