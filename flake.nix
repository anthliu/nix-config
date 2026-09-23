{
  description = "anthliu NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home Manager (Follows the same branch as nixpkgs for compatibility)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      # niri-flake currently requires libdisplay-info 0.2, which was removed
      # from newer nixpkgs. Keep its package build on the last tested revision
      # while allowing the rest of the system to track current unstable.
      inputs.nixpkgs.follows = "nixpkgs-niri";
    };
    nixpkgs-niri.url = "github:nixos/nixpkgs/643809054d65fdd466a63e3155b8c498cb483c04";
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tracks upstream Claude Code releases faster than nixpkgs
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      mkHost =
        module:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ module ];
        };
    in
    {
      nixosConfigurations = {
        ganymede = mkHost ./hosts/ganymede/default.nix;
        europa = mkHost ./hosts/europa/default.nix;
        thebe = mkHost ./hosts/thebe/default.nix;
        callisto = mkHost ./hosts/callisto/default.nix;
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
