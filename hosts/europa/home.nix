{ ... }:

{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/graphical.nix
    ../../modules/home-manager/features/local-ai.nix
    ../../modules/home-manager/features/niri.nix
    ../../modules/home-manager/features/qmk.nix
    ../../modules/home-manager/features/swayidle.nix
    ../../modules/shared/stylix.nix
  ];

  programs.niri.settings.outputs."Dell Inc. DELL P2723DE 8VCSX34" = {
    mode = {
      width = 2560;
      height = 1440;
      refresh = 59.951;
    };
    scale = 1.0;
    position = {
      x = 0;
      y = 0;
    };
  };

  home.stateVersion = "26.11";
}
