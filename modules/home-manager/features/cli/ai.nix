{ pkgs, ... }:

{
  home.packages = [
    pkgs.llama-cpp
    pkgs.opencode
    pkgs.nvtopPackages.full
  ];
}
