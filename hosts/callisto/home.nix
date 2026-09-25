{ pkgs, ... }:

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

  # DMS's integrated lock-before-suspend path has been unreliable here. This
  # explicit sequence was tested across lock, suspend, wake, and PAM unlock.
  custom.idle.extraBeforeSleepCommand = ''
    ${pkgs.dms-shell}/bin/dms ipc call lock lock
    ${pkgs.coreutils}/bin/sleep 1
  '';

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
