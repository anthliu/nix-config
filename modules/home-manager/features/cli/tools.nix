{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Basic Utilities
    wget
    curl
    tmux
    htop
    fastfetch
    
    # Modern CLI Tools
    ripgrep
    jq
    fzf
  ];
}
