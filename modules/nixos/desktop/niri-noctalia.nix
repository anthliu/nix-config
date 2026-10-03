{ pkgs, config, lib, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
  greeter = config.services.displayManager.regreet;
  niri = lib.getExe config.programs.niri.package;
  # Match desktop monitor identities so docking into another port keeps the scale.
  # Keep widget sizes fixed in logical pixels, using the normal desktop DPI scale.
  # Unlisted displays retain Niri's automatic DPI.
  outputs = config.home-manager.users.anthliu.programs.niri.settings.outputs;
  outputRules = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: output:
    lib.optionalString (output.scale != null) ''
      output ${builtins.toJSON name} {
        scale ${toString output.scale}
      }
    ''
  ) outputs);
  greeterConfig = pkgs.writeTextFile {
    name = "regreet-niri.kdl";
    text = ''
      ${outputRules}
      spawn-sh-at-startup ${builtins.toJSON "${lib.getExe greeter.package}; ${niri} msg action quit --skip-confirmation"}
      hotkey-overlay { skip-at-startup; }
      cursor {
        xcursor-theme ${builtins.toJSON config.stylix.cursor.name}
        xcursor-size ${toString config.stylix.cursor.size}
      }
      input {
        keyboard { xkb { layout "us"; }; }
      }
      environment {
        GTK_USE_PORTAL "0"
        GDK_DEBUG "no-portals"
        GDK_BACKEND "wayland"
        XDG_DATA_DIRS ${builtins.toJSON "${config.services.displayManager.sessionData.desktops}/share:/run/current-system/sw/share"}
      }
      layout {
        gaps 0
        border { off; }
        focus-ring { off; }
        background-color ${builtins.toJSON colors.base00}
      }
      binds {
        Mod+Shift+Left { move-window-to-monitor-left; }
        Mod+Shift+Right { move-window-to-monitor-right; }
      }
    '';
    checkPhase = ''${niri} validate --config "$target"'';
  };
in

{
  imports = [ ./niri-base.nix ];

  services.upower.enable = true;

  # Style directly: Stylix's ReGreet target assumes the default Cage command.
  stylix.targets.regreet.enable = false;

  services.displayManager.regreet = {
    enable = true;
    font = {
      inherit (config.stylix.fonts.sansSerif) name package;
      size = 14;
    };
    cursorTheme = {
      inherit (config.stylix.cursor) name package;
    };
    settings = {
      skip_selection = true;
      background = {
        path = config.stylix.image;
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = config.stylix.polarity == "dark";
      appearance.greeting_msg = "";
      widget.clock = {
        format = "<span font_family='Roboto' size='86016' weight='medium' font_features='tnum=1'>%I:%M</span>\n<span size='14336'>%a, %b %-d</span>";
        resolution = "1s";
        label_width = 520;
        locale = "en_US";
      };
    };
    extraCss = ''
      @define-color window_bg_color ${colors.base00};
      @define-color window_fg_color ${colors.base05};
      @define-color view_bg_color ${colors.base01};
      @define-color view_fg_color ${colors.base05};
      @define-color popover_bg_color ${colors.base01};
      @define-color popover_fg_color ${colors.base05};
      @define-color accent_color ${colors.base0D};
      @define-color accent_bg_color ${colors.base0D};
      @define-color accent_fg_color ${colors.base00};
      @define-color destructive_color ${colors.base08};

      window.background { color: ${colors.base05}; background: ${colors.base00}; }
      overlay > picture { opacity: 0.45; }
      overlay > frame.background {
        background: transparent;
        border: none;
        box-shadow: none;
      }
      overlay > frame.background > label {
        margin-top: 64px;
        color: ${colors.base05};
      }
      entry, combobox button {
        background: alpha(${colors.base00}, 0.88);
        color: ${colors.base05};
        border: 1px solid transparent;
        border-radius: 12px;
        box-shadow: none;
        min-height: 36px;
        padding: 6px 14px;
      }
      entry:focus-within,
      combobox:focus-within button,
      combobox button:checked {
        border-color: ${colors.base0D};
      }
      button {
        background: alpha(${colors.base00}, 0.62);
        color: ${colors.base04};
        border: none;
        border-radius: 12px;
        box-shadow: none;
        font-size: 12pt;
        padding: 6px 18px;
        transition: background-color 120ms ease, color 120ms ease, box-shadow 120ms ease;
      }
      combobox button { font-size: ${toString greeter.font.size}pt; }
      button.suggested-action {
        background: ${colors.base0D};
        color: ${colors.base00};
        border: none;
        padding: 6px 18px;
      }
      button.destructive-action {
        background: alpha(${colors.base00}, 0.48);
        color: ${colors.base04};
        border: none;
        padding: 6px 18px;
      }

      /* Preserve interaction feedback when overriding the native theme. */
      button:hover {
        background: alpha(${colors.base02}, 0.94);
        color: ${colors.base05};
      }
      button:active, button:checked {
        background: alpha(${colors.base03}, 0.94);
      }
      button:active {
        box-shadow: inset 0 2px 3px alpha(${colors.base00}, 0.45);
        transition-duration: 60ms;
      }
      button.suggested-action:hover {
        background: mix(${colors.base0D}, ${colors.base05}, 0.16);
        color: ${colors.base00};
      }
      button.suggested-action:active {
        background: mix(${colors.base0D}, ${colors.base00}, 0.22);
        color: ${colors.base00};
      }
      button.destructive-action:hover {
        background: alpha(${colors.base02}, 0.94);
      }
      button.destructive-action:active {
        background: alpha(${colors.base03}, 0.94);
      }
      combobox button:hover { background: alpha(${colors.base01}, 0.94); }
      combobox button:active, combobox button:checked {
        background: alpha(${colors.base02}, 0.94);
      }
      button:disabled {
        color: alpha(${colors.base04}, 0.55);
        box-shadow: none;
      }
    '';
  };

  # ReGreet's documented Niri session exits the greeter compositor after login.
  services.greetd.settings.default_session.command =
    "${pkgs.dbus}/bin/dbus-run-session ${niri} --config /etc/greetd/niri.kdl";
  environment.etc."greetd/niri.kdl".source = greeterConfig;
  environment.systemPackages = [ greeter.package ];
}
