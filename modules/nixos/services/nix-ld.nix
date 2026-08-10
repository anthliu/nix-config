{ pkgs, lib, options, config, ... }:

let
  # True only where the NixOS-WSL module is imported, since that module is what
  # declares the `wsl` option tree. Checking `options` rather than `config.wsl`
  # keeps this file evaluable on hosts that never import it, where reading
  # `config.wsl` would be an undefined-option error.
  isWSL = options ? wsl;
in
{
  # --- Nix-ld Configuration ---
  # Required for tools like uv that download and run unpatched binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    libgcc
    glib
    gtk3
    libsecret
    nss

    # for OpenCV / cv2:
    libSM
    libICE
    libx11
    libxext
    libxrender
    libxfixes
    libxcursor
    libxcomposite
    libxdamage
    libxrandr
    fontconfig
    freetype
    libglvnd
    libxcb
  ]

  # for JAX/CUDA:
  #
  # nvidia_x11 ships the userspace half of the native driver, whose
  # libcuda.so.1 talks to the /dev/nvidia* nodes created by the nvidia kernel
  # module. WSL has no such module: the GPU is reached through Microsoft's
  # /dev/dxg, and only the libcuda.so.1 that Windows injects at
  # /usr/lib/wsl/lib speaks that protocol. Both libraries carry the same
  # soname, so including nvidia_x11 here would win the NIX_LD_LIBRARY_PATH
  # lookup and leave every CUDA consumer reporting no visible device. The WSL
  # copy is added at the end of this list instead.
  ++ lib.optionals (!isWSL) [ linuxPackages.nvidia_x11 ]

  ++ (with pkgs; [
    cudaPackages.cuda_nvrtc
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
  ])

  # cudatoolkit is the monolithic bundle: it re-exports the redistributable
  # libraries listed just above and adds ~1.7 GiB of headers, static archives
  # and nvcc that only matter when compiling CUDA sources locally. Runtime
  # consumers such as prebuilt pip wheels need only the individual libraries.
  ++ lib.optionals (!isWSL) [ pkgs.cudaPackages.cudatoolkit ]

  # sometimes required:
  ++ (with pkgs; [
    libxi
    libxmu
    libGL
    pciutils
  ])

  # The WSL-side libcuda.so.1, libnvidia-ml.so.1 and d3d12 stack, symlinked out
  # of /usr/lib/wsl/lib by the derivation `wsl.useWindowsDriver` installs. That
  # option only publishes them under /run/opengl-driver, a path the dynamic
  # loader does not search unless a program was linked with it in its RUNPATH;
  # unpatched binaries resolve libraries through NIX_LD_LIBRARY_PATH instead, so
  # they have to be named here too. Reusing hardware.graphics.extraPackages
  # rather than restating the paths keeps both consumers on one definition.
  ++ lib.optionals isWSL config.hardware.graphics.extraPackages;
}
