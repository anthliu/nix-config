{
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./battery.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/users/anthliu.nix
    ../../modules/nixos/desktop/niri-noctalia.nix
    ../../modules/nixos/desktop/stylix.nix
    ./theme.nix
    ../../modules/nixos/services/nix-ld.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/hardware/swap.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
  ];

  networking.hostName = "callisto";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [ pkgs.brightnessctl ];
  services.fwupd.enable = true;

  # The built-in Synaptics reader (06cb:00f9) is supported by libfprint.
  services.fprintd.enable = true;
  # Noctalia checks passwords through login PAM and scans fingerprints separately.
  # Keep its password check from starting another fingerprint conversation.
  security.pam.services.login.fprintAuth = false;
  # ReGreet starts authentication automatically for the remembered user/session.
  # A successful scan completes authentication; failure falls through to login PAM.
  security.pam.services.greetd.rules.auth.fprintd = {
    order = config.security.pam.services.greetd.rules.auth.login.order - 10;
    control = "sufficient";
    modulePath = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
    settings = {
      timeout = 30;
      "max-tries" = 3;
    };
  };

  # The lock screen can start fingerprint authentication before suspend.
  # If fprintd still owns the Synaptics USB reader when it resets for sleep, the
  # daemon keeps a stale handle after resume and reports an unsupported firmware
  # version. Stop it at the sleep boundary; D-Bus starts a clean instance for
  # the next fingerprint request after wake.
  systemd.services.stop-fprintd-before-sleep = {
    description = "Stop fprintd before sleep";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.procps}/bin/pkill -x fprintd || true
    '';
  };

  # Noctalia reads batteries through UPower and changes power modes through
  # power-profiles-daemon. This also disables the laptop module's default TLP.
  services.power-profiles-daemon.enable = true;

  # The external keyboard already swaps these keys in its own firmware. Apply
  # the remap only to the ThinkPad's built-in AT keyboard to avoid swapping it
  # a second time on external keyboards.
  services.keyd = {
    enable = true;
    keyboards.thinkpad = {
      ids = [ "0001:0001" ];
      settings.main = {
        capslock = "leftcontrol";
        leftcontrol = "capslock";
      };
    };
  };

  # The generic ThinkPad module defaults to the older IBM device name, so its
  # TrackPoint tuning service otherwise never matches this laptop's hardware.
  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";

  users.users.anthliu.extraGroups = [
    "networkmanager"
    "wheel"
    "audio"
    "video"
  ];
  home-manager.users.anthliu = import ./home.nix;

  system.stateVersion = "25.11";
}
