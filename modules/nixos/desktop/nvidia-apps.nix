{ ... }:

{
  # Application-specific NVIDIA acceleration policy. These overrides are kept
  # separate from the driver so the generic hardware module stays reusable.
  nixpkgs.overlays = [
    (_final: prev: {
      firefox = prev.firefox.overrideAttrs (old: {
        makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
          "--set"
          "__EGL_VENDOR_LIBRARY_FILENAMES"
          "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json"
          "--set"
          "LIBVA_DRIVER_NAME"
          "nvidia"
          "--set"
          "MOZ_DISABLE_RDD_SANDBOX"
          "1"
          "--set"
          "NVD_BACKEND"
          "direct"
        ];
      });

      google-chrome = prev.google-chrome.override {
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--ignore-gpu-blocklist"
          "--enable-features=VaapiVideoDecodeLinuxGL"
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
          "--disable-features=UseChromeOSDirectVideoDecoder,DefaultANGLEVulkan,VulkanFromANGLE"
        ];
      };
    })
  ];
}
