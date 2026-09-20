{ config, pkgs, ... }:

{
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  programs.nix-ld.libraries = with pkgs; [
    # The native driver userspace library talks to /dev/nvidia* provided by the
    # kernel module. It must not be used in WSL, which has a different libcuda.
    config.hardware.nvidia.package
    cudaPackages.cuda_nvrtc
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    cudaPackages.cudatoolkit
  ];

  environment.variables.TRITON_LIBCUDA_PATH = "/run/opengl-driver/lib";

  nixpkgs.overlays = [
    (_final: prev: {
      llama-cpp = prev.llama-cpp.override { cudaSupport = true; };
    })
  ];
}
