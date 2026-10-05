{ config, lib, pkgs, ... }:

let
  nvidia = config.hardware.nvidia;
  # Match nixpkgs' systemd power-management path; kernel notifiers handle
  # GPU restoration themselves when enabled.
  useSleepHook = nvidia.powerManagement.enable && !nvidia.powerManagement.kernelSuspendNotifier;
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      egl-wayland
      nvidia-vaapi-driver
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # NVIDIA's systemd resume service runs after user.slice is thawed.
  # Install the vendor sleep hook so GPU restoration finishes before desktop
  # clients resume and attempt DRM/gamma updates.
  environment.etc."systemd/system-sleep/nvidia" = lib.mkIf useSleepHook {
    source = "${nvidia.package.out}/lib/systemd/system-sleep/nvidia";
  };

  # The vendor hook calls nvidia-sleep.sh, which needs cat, rm, and chvt.
  # NixOS adds coreutils to service paths; kbd supplies chvt.
  systemd.services = lib.mkIf useSleepHook (
    lib.genAttrs
      [
        "systemd-suspend"
        "systemd-hibernate"
        "systemd-hybrid-sleep"
        "systemd-suspend-then-hibernate"
      ]
      (_: { path = [ pkgs.kbd ]; })
  );

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
