{ pkgs, ... }:

{
  imports = [
  ];

  home.packages = with pkgs; [
    gcc
    uv
    qmk
    dos2unix

    # AI Tools
    llama-cpp
    claude-code
    gemini-cli
    opencode
    lmstudio
    nvtopPackages.full
  ];
}
