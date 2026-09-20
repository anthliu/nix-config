{ config, ... }:

{
  # The WSL-side libcuda.so.1, libnvidia-ml.so.1, and D3D12 stack are supplied
  # by Windows. Native nvidia_x11 cannot communicate through /dev/dxg.
  programs.nix-ld.libraries = config.hardware.graphics.extraPackages;
}
