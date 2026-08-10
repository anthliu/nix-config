{ config, pkgs, lib, ... }@args:

let
  # Home Manager passes the surrounding NixOS configuration as `osConfig` when
  # it runs as a NixOS module, which lets a shared profile branch on properties
  # of the host it was imported into. A standalone `home-manager switch` has no
  # system config to pass, so the argument is absent there and the default keeps
  # this file evaluable either way.
  osConfig = args.osConfig or { };

  # `wsl.enable` is set only by the NixOS-WSL module, so this marks a host with
  # no display of its own. Packages whose value is entirely graphical, or whose
  # dependency closure is dominated by GUI libraries, are skipped when true.
  headless = osConfig.wsl.enable or false;
in
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
  ]
  # fastfetch probes the desktop environment for its output, so it links efl,
  # gtk3, ghostscript-with-X and several icon theme packages: a 1.6 GiB closure
  # for a terminal banner, nearly all of it unreachable without a display.
  ++ lib.optionals (!headless) [ fastfetch ]
  ++ (with pkgs; [
    tree
    # The two builds share a codec set; ffmpeg-headless drops only the X11 and
    # SDL output devices, which are what `ffplay` and `-f sdl` would need.
    (if headless then ffmpeg-headless else ffmpeg)

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
  ]);
}
