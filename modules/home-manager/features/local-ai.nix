{ pkgs, ... }:

{
  home.packages = with pkgs; [
    llama-cpp
    nvtopPackages.full
  ];
}
