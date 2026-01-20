{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/nixos/base.nix
    ../../modules/nixos/services/nix-ld.nix
    inputs.home-manager.nixosModules.default
  ];

  wsl.enable = true;
  wsl.defaultUser = "anthliu";

  # Define the user explicitly for consistent permissions/groups
  users.users.anthliu = {
    isNormalUser = true;
    description = "Anthony Liu";
    extraGroups = [ "wheel" ];
  };

  networking.hostName = "nixos-wsl";

  # Home Manager Configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      "anthliu" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  # Disable systemd-oomd to fix "Device or resource busy" errors in WSL
  # which prevent the user session from starting.
  systemd.oomd.enable = false;

  system.stateVersion = "25.11";
}
