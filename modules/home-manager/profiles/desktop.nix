{ pkgs, inputs, lib, options, ... }:

{
  imports = [
    ../features/niri.nix
    ../features/swayidle.nix
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "none";
      };
    };
    # Stylix will automatically configure fonts and colors
  };

  programs.foot = {
    enable = true;
    settings = {
      csd = {
        preferred = "none";
        size = 0;
      };
    };
    # Stylix will automatically configure fonts and colors
  };

  home.packages = let
    antigravity-wrapped = pkgs.symlinkJoin {
      name = "antigravity";
      paths = [ inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/antigravity \
          --add-flags "--disable-gpu"
      '';
    };
  in [
    antigravity-wrapped
    pkgs.google-chrome
    pkgs.vlc
    # vesktop instead of vanilla discord: its venmic/PipeWire screencast works
    # on NVIDIA (vanilla discord's bundled webrtc fails dmabuf negotiation) and
    # it can share screen audio. Native Wayland is handled by NIXOS_OZONE_WL in
    # the niri session env (see modules/home-manager/features/niri.nix).
    pkgs.vesktop
    pkgs.shotcut
  ];



  programs.mpv = {
    enable = true;
    config = {
      autofit-larger = "100%x100%";
      loop-file = "inf";
    };
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default = {
      id = 0;
      isDefault = true;
    };
  };

  gtk = {
    enable = true;
  };
}
