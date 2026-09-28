{ pkgs, ... }:

{
  imports = [ ./niri-base.nix ];

  # The nixpkgs module starts greetd and Noctalia's bundled greeter compositor.
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      user.default = "anthliu";
      auth.allow_empty_password = true; # Submit a blank field to start fingerprint PAM.
      idle.timeout = 300;
      appearance.wallpaper.path = "${../../../assets/wallpaper.png}";
      keyboard.layout = "us";
      cursor.size = 24;
    };
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
