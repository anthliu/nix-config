{ pkgs, config, lib, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
in

{
  imports = [ ./niri-base.nix ];

  services.upower.enable = true;

  # The nixpkgs module starts greetd and Noctalia's bundled greeter compositor.
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      user.default = "anthliu";
      idle.timeout = 300;
      appearance = {
        scheme = "Synced";
        theme_mode = config.stylix.polarity;
        font_family = config.stylix.fonts.sansSerif.name;
        wallpaper.path = config.stylix.image;
        # Match the semantic colors Stylix supplies to Noctalia Shell.
        palette = {
          primary = colors.base0D;
          on_primary = colors.base00;
          secondary = colors.base0E;
          on_secondary = colors.base00;
          tertiary = colors.base0C;
          on_tertiary = colors.base00;
          error = colors.base08;
          on_error = colors.base00;
          surface = colors.base00;
          on_surface = colors.base05;
          surface_variant = colors.base01;
          on_surface_variant = colors.base04;
          outline = colors.base03;
          shadow = colors.base00;
          hover = colors.base0C;
          on_hover = colors.base00;
        };
      };
      keyboard.layout = "us";
      cursor.size = 24;
    };
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  # AccountsService supplies the same avatar before the user session starts.
  systemd.services.noctalia-avatar = {
    description = "Set Noctalia greeter avatar";
    wantedBy = [ "multi-user.target" ];
    requires = [ "accounts-daemon.service" ];
    after = [ "accounts-daemon.service" ];
    before = [ "greetd.service" ];
    environment.AVATAR = lib.mkDefault "${../../../assets/gustav-avatar.jpg}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      user_id="$(${pkgs.coreutils}/bin/id -u anthliu)"
      ${pkgs.systemd}/bin/busctl --system call \
        org.freedesktop.Accounts /org/freedesktop/Accounts \
        org.freedesktop.Accounts FindUserByName s anthliu >/dev/null
      ${pkgs.systemd}/bin/busctl --system call \
        org.freedesktop.Accounts "/org/freedesktop/Accounts/User$user_id" \
        org.freedesktop.Accounts.User SetIconFile s \
        "$AVATAR"
    '';
  };
}
