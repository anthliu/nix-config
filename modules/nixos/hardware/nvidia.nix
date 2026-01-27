{ config, lib, pkgs, ... }:

{
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };

  # 1. Enable OpenGL (required for the driver to work)
  # Note: On newer NixOS versions (24.11+), this is 'hardware.graphics'
  # On older versions, it was 'hardware.opengl'
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      egl-wayland
      nvidia-vaapi-driver
    ];
  };

  # 3. Load the Nvidia drivers for X11 and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # 4. Configure the Nvidia hardware
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Power management can be experimental. 
    # Enable if you see graphical corruption after suspend/wake.
    powerManagement.enable = true;
    
    # Fine-grained power management (only for Turing+ GPUs). 
    # Turns off GPU when not in use. Experimental.
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with Nouveau).
    # 'false' uses the proprietary kernel module
    open = true;

    # Enable the Nvidia settings menu (accessible via `nvidia-settings`).
    nvidiaSettings = true;

    # Choose the package version (Stable, Beta, etc.)
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  nixpkgs.overlays = [
    (final: prev: {
      llama-cpp = prev.llama-cpp.override { cudaSupport = true; };
      
      firefox = prev.firefox.overrideAttrs (old: {
        makeWrapperArgs = (old.makeWrapperArgs or []) ++ [
          "--set" "__EGL_VENDOR_LIBRARY_FILENAMES" "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json"
          "--set" "LIBVA_DRIVER_NAME" "nvidia"
          "--set" "MOZ_DISABLE_RDD_SANDBOX" "1"
          "--set" "NVD_BACKEND" "direct"
        ];
      });
    })
  ];
}
