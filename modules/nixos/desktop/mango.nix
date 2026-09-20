{ pkgs, inputs, ... }:

{
  imports = [
    inputs.mango.nixosModules.mango
    ./dms.nix
    ./wayland-common.nix
  ];

  # --- Mango Compositor ---
  programs.mango.enable = true;

  # --- NVIDIA + wlroots workarounds ---
  # Mango uses wlroots which needs Vulkan renderer on NVIDIA (GLES2 is broken).
  # These are not needed for niri since it has its own renderer.
  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Fix: Ensure DMS can find quickshell (qs) and system utilities
  # We use the standard NixOS 'path' attribute which appends to the unit environment
  systemd.user.services.dms = {
    path = with pkgs; [
      quickshell
      bash
      coreutils
      gnugrep
      procps
      which
      "/run/wrappers"
    ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.StartLimitBurst = 10;
  };

  # --- Display Manager (GDM) ---
  services.xserver.enable = true;
  services.displayManager.gdm = {
    enable = true;
    settings = {
      greeter = {
        Exclude = "root";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    quickshell # Needed for the DMS shell UI components
    xwayland-satellite
    wlopm
  ];
}
