{ pkgs, ... }:

{
  imports = [
    ../features/cli/ai.nix
  ];

  home.packages = with pkgs; [
    uv
  ];
}
