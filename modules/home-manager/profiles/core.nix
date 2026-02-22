{ config, pkgs, ... }:

{
  imports = [
    ../features/vim.nix
  ];

  programs.git = {
    enable = true;
    
    settings = {
      init.defaultBranch = "main";
      user.name = "Anthony Liu";
      user.email = "anthzliu@gmail.com.com";
      # safe.directory = "/home/anthliu/nix-config"; # useful if git complains about ownership
    };
  };

  programs.ssh = {
    enable = true;

    # If you find SSH stops working for other servers, comment this line out.
    # enableDefaultConfig = false; 

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519"; 
        identitiesOnly = true;
      };
    };

  };

  home.file.".ssh/id_ed25519.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyF+oMBRjYwqIO7JLZ/YzefHDbRsrW3LouCCI/RJ5Ws anthzliu@gmail.com";

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
