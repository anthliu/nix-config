{ pkgs, inputs, lib, ... }@args:

let
  # `osConfig` is the surrounding NixOS configuration, supplied only when Home
  # Manager runs as a NixOS module; the default keeps standalone evaluation
  # working. `wsl.enable` comes from the NixOS-WSL module and so identifies a
  # host with no display and no USB access of its own.
  osConfig = args.osConfig or { };
  headless = osConfig.wsl.enable or false;
in
{
  imports = [
  ];

  home.packages = with pkgs; [
    gcc
    uv
  ]
  # qmk builds and flashes keyboard firmware, which requires claiming the
  # keyboard's USB device in bootloader mode. A WSL guest sees no USB bus unless
  # devices are explicitly attached from the Windows side via usbip, so the
  # flashing half cannot work there and the 2.1 GiB toolchain has no use.
  ++ lib.optionals (!headless) [ qmk ]
  ++ (with pkgs; [
    dos2unix
    (python313.withPackages (ps: [ ps.tkinter ]))

    # AI Tools
    llama-cpp
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    gemini-cli
    opencode
  ])
  # lmstudio is an Electron front-end shipped inside an FHS sandbox, so its
  # 3.7 GiB closure is the browser runtime and a private glibc tree rather than
  # inference code. Its only interface is the GUI; llama-cpp above serves the
  # same models from the command line in 212 MiB.
  ++ lib.optionals (!headless) [ lmstudio ]
  ++ (with pkgs; [
    nvtopPackages.full

    # LaTeX (CLI tools: full install to include enumitem, etc.)
    texliveFull
    poppler-utils # utils for agents to read pdf
  ]);
}
