{ pkgs, ... }:

{
  home.packages = [
    pkgs.llama-cpp
    pkgs.claude-code
    pkgs.gemini-cli
    pkgs.opencode
    pkgs.nvtopPackages.full
  ];
}
