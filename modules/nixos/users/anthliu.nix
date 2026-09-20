{ inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.default ];

  users.users.anthliu = {
    isNormalUser = true;
    description = "Anthony Liu";
  };

  # Home Manager is intentionally integrated into the NixOS generation. This
  # gives the home configuration the same nixpkgs instance and overlays as its
  # host, and leaves one activation path responsible for the user's dotfiles.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
  };
}
