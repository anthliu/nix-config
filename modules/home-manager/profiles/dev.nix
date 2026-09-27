{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    uv
    dos2unix
    (python313.withPackages (ps: [ ps.tkinter ]))

    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    antigravity-cli
    opencode
    codex
    pi-coding-agent

    texliveFull
    poppler-utils
  ];
}
