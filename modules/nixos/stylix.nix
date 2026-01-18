{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ../../assets/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    
    # GDM Specific
    cursor.package = pkgs.adwaita-icon-theme;
    cursor.name = "Adwaita";
    cursor.size = 24;
    
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
    };

    # This will apply the background to GDM
    targets.gnome.enable = true;
    targets.gtk.enable = true;
  };
}
