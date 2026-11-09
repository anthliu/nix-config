{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    uv
    dos2unix
    (python313.withPackages (ps: [ ps.tkinter ]))

    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
    pi-coding-agent

    texliveFull
    poppler-utils
  ];
}
