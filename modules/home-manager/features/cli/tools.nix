{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Basic Utilities
    htop
    fastfetch
    tree
    
    # Modern CLI Tools
    ripgrep
    jq
    fzf
  ];
}
