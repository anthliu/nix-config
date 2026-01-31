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
    enableDefaultConfig = false; 

    matchBlocks = {
      # Settings here apply to every SSH connection
      "*" = {
        # Using 'extraOptions' ensures it writes the raw config line safely.
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519"; 
      };
    };
  };

  home.packages = with pkgs; [
    # Basic Utilities
    htop
    fastfetch
    tree
    
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
