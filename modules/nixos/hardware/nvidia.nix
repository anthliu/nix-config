{ config, lib, pkgs, ... }:

let
  gputemps = pkgs.callPackage ../../../packages/gputemps { };
in
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
    open = false;

    # Enable the Nvidia settings menu (accessible via `nvidia-settings`).
    nvidiaSettings = true;

    # Choose the package version (Stable, Beta, etc.)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # --- VRAM Temperature Monitoring ---
  # These settings are required for the GDDR6 VRAM temperature tool:
  # https://github.com/ThomasBaruzier/gddr6-core-junction-vram-temps
  
  # iomem=relaxed is required to access the GPU memory space via /dev/mem
  boot.kernelParams = [ "iomem=relaxed" ];

  # pciutils provides libpci.so and lspci, required for the tool to interact with the hardware
  environment.systemPackages = [ pkgs.pciutils gputemps ];

  # setuid wrapper so gputemps can access /dev/mem without manual sudo
  security.wrappers.gputemps = {
    source = "${gputemps}/bin/gputemps";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Deploy gputemps DMS-Shell bar widget plugin (only when DMS is enabled)
  environment.etc = lib.mkIf config.programs.dms-shell.enable (let
    gputemps-dms-plugin = pkgs.callPackage ../../../packages/gputemps-dms-plugin { };
  in {
    "xdg/quickshell/dms-plugins/gpuTemps/plugin.json".source =
      "${gputemps-dms-plugin}/share/dms-plugins/gpuTemps/plugin.json";
    "xdg/quickshell/dms-plugins/gpuTemps/GpuTempsWidget.qml".source =
      "${gputemps-dms-plugin}/share/dms-plugins/gpuTemps/GpuTempsWidget.qml";
  });

  environment.variables = {
    TRITON_LIBCUDA_PATH = "/run/opengl-driver/lib";
  };

  # --- GPU Power Tuning (RTX 3090) ---
  # Enables persistence mode and caps power to 330W.
  # 330W is a good balance: ~6% power reduction vs default 350W with negligible perf loss for AI.
  # Clock locking is intentionally omitted — the driver's P-state management + the
  # power cap naturally finds the optimal clock/voltage point, and locking prevents
  # efficient idle downclocking (wastes ~30-50W at idle).
  systemd.services.nvidia-power-tuning = {
    description = "NVIDIA GPU Power Configuration (RTX 3090)";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-persistenced.service" ];
    script = ''
      NVIDIA_SMI="${config.hardware.nvidia.package.bin}/bin/nvidia-smi"

      # Enable persistence mode (keeps driver loaded, avoids cold-start latency)
      $NVIDIA_SMI -pm 1

      # Cap power limit to 330W (default is 350W for RTX 3090 XC3 Hybrid)
      # Increase toward 350W if you need max training throughput
      $NVIDIA_SMI -pl 330
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
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
