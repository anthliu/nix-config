{ pkgs, ... }:

{
  home.packages = [
    pkgs.llama-cpp
    pkgs.nvtopPackages.full
  ];
}
