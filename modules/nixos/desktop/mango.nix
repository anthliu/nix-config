{ pkgs, inputs, ... }:

{
  imports = [
    inputs.mango.nixosModules.mango
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
    xwayland-satellite
    wlopm
  ];
}
