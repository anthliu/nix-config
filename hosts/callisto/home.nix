{ pkgs, inputs, config, lib, ... }:

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
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    package = pkgs.noctalia;
    systemd.enable = true;
    settings = {
      shell.launch_apps_as_systemd_services = true;
      theme.mode = lib.mkForce "dark";
      wallpaper.enabled = true;
      bar.default = {
        start = [ "launcher" "workspaces" ];
        center = [ "clock" ];
        end = [
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "power_profile"
          "battery"
          "tray"
          "notifications"
          "control-center"
          "session"
        ];
      };
    };
  };

  # Keep the explicit lock-before-suspend sequence used by this laptop's idle
  # service until its suspend and fingerprint path is tested with Noctalia.
  custom.idle.extraBeforeSleepCommand = ''
    ${pkgs.noctalia}/bin/noctalia msg session lock
    ${pkgs.coreutils}/bin/sleep 1
  '';

  programs.niri.settings = {
    binds = {
      "Mod+Space".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "panel-toggle" "launcher";
      "Mod+Shift+Space".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "panel-toggle" "control-center";
      "Mod+Ctrl+Comma".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "settings-toggle";
      "Mod+Alt+L".action = config.lib.niri.actions.spawn "${pkgs.noctalia}/bin/noctalia" "msg" "session" "lock";
    };
    window-rules = [
      {
        matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
        open-floating = true;
      }
    ];
  };

  # Slow only the built-in touchpad on Callisto. Keeping this host-local avoids
  # changing touchpad behavior on the desktop hosts or any mouse-wheel events.
  programs.niri.settings.input.touchpad.scroll-factor = 0.5;

  programs.niri.settings.outputs = {
    "InfoVision Optoelectronics (Kunshan) Co.,Ltd China 0x057D Unknown".scale = 1.0;

    "Dell Inc. AW3423DWF BDRK2S3" = {
      mode = {
        width = 3440;
        height = 1440;
        refresh = 164.900;
      };
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };

    "Samsung Electric Company Odyssey G81SF HNBYA00490" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 239.996;
      };
      scale = 1.25;
      position = {
        x = 3440;
        y = 0;
      };
    };

    "Dell Inc. DELL P2723DE 8VCSX34" = {
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
  };

  home.stateVersion = "25.11";
}
