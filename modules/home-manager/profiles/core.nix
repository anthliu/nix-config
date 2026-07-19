{ config, pkgs, ... }:

{
  imports = [
    ../features/vim.nix
  ];

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    
    settings = {
      init.defaultBranch = "main";
      user.name = "Anthony Liu";
      user.email = "anthzliu@gmail.com";
      # safe.directory = "/home/anthliu/nix-config"; # useful if git complains about ownership
    };
  };

  programs.ssh = {
    enable = true;

    # If you find SSH stops working for other servers, comment this line out.
    enableDefaultConfig = false; 

    # Attribute names become `Host <name>` blocks; values are literal
    # ssh_config(5) keywords.
    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
    };

  };

  home.packages = with pkgs; [
    # Basic Utilities
    htop
    fastfetch
    tree
    ffmpeg
    
    # Modern CLI Tools
    ripgrep
    jq
    fzf
    bat
    eza
    fd
    tealdeer
    ncdu
    dust

    # Compression Utilities
    zip
    unzip
    p7zip
    xz
    zstd
    unrar
  ];
}
