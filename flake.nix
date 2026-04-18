{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, systems, ... }@inputs: {
    eachSystem = systems.lib.genAttrs [ "x86_64-linux" ];

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ inputs.nur.overlays.default ];
      };

    nixosConfigurations = {
      c0d3h01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/nixos
          inputs.home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.c0d3h01.imports = [ ./modules/home ];
            };
          }
        ];
      };
    };

    homeConfigurations = {
      c0d3h01 = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        modules = [ ./modules/home ];
      };
    };

    devShells = eachSystem (system: {
      default = import ./shell.nix { inherit (mkPkgs system) pkgs; };
    });

    formatter = eachSystem (system: (import ./formatter.nix { inherit self; pkgs = mkPkgs system; }).formatter);

    checks = eachSystem (system: {
      formatting = (import ./formatter.nix { inherit self; pkgs = mkPkgs system; }).check;
    });
  };
}
