{ ... }:

{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/graphical.nix
    ../../modules/home-manager/features/local-ai.nix
    ../../modules/home-manager/features/niri.nix
    ../../modules/home-manager/features/noctalia.nix
    ../../modules/home-manager/features/qmk.nix
    ../../modules/home-manager/features/swayidle.nix
    ../../modules/shared/stylix.nix
    ./theme.nix
  ];

  wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "Dell Inc. DELL P2723DE 8VCSX34" ];
        mode = "2560x1440@59.951";
        scale = 1.0;
        position._props = {
          x = 0;
          y = 0;
        };
      };
    }
  ];

  home.stateVersion = "26.11";
}
