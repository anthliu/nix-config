{ ... }:

{
  imports = [
    ../../modules/home-manager/profiles/core.nix
    ../../modules/home-manager/profiles/dev.nix
    ../../modules/home-manager/profiles/headless.nix
    ../../modules/home-manager/features/local-ai.nix
  ];

  home.stateVersion = "25.11";
}
