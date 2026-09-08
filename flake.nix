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
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      ganymede = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/ganymede/default.nix
        ];
      };

      thebe = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/thebe/default.nix
        ];
      };

      europa = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/europa/default.nix
        ];
      };
    };

    homeConfigurations = {
      "anthliu@ganymede" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/ganymede/home.nix
          inputs.stylix.homeModules.stylix
        ];
      };

      # thebe has no entry here on purpose. Its user environment is built by
      # the home-manager NixOS module in hosts/thebe/default.nix, which
      # installs into /etc/profiles/per-user and activates from a system unit. A
      # homeConfigurations entry would be a second, independent generation of
      # the same home.nix, installing into ~/.nix-profile and claiming the same
      # dotfiles; whichever of `home-manager switch` and `nixos-rebuild switch`
      # ran last would own them, silently displacing the other's files. Build
      # that host with `nixos-rebuild switch --flake .#thebe`.
    };
  };
}
