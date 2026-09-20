{
  lib,
  options,
  pkgs,
  ...
}:

{
  config = lib.mkMerge [
    {
      stylix = {
        enable = true;
        image = ../../assets/wallpaper.png;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/horizon-dark.yaml";

        cursor = {
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.fira-code;
            name = "FiraCode Nerd Font Mono";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
          serif = {
            package = pkgs.inter;
            name = "Inter";
          };
          sizes = {
            terminal = 11;
            applications = 11;
            desktop = 11;
          };
        };

        targets.gnome.enable = true;
        targets.gtk.enable = true;
      };
    }

    (lib.optionalAttrs (options.stylix.targets ? firefox) {
      stylix.targets.firefox.profileNames = [ "default" ];
    })
  ];
}
