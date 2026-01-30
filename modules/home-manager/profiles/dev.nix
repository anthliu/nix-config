{ pkgs, ... }:

{
  imports = [
  ];

  home.packages = with pkgs; [
    uv
    qmk
    dos2unix

    # AI Tools
    llama-cpp
    claude-code
    gemini-cli
    opencode
    nvtopPackages.full
  ];
}
