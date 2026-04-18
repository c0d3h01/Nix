{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    disko.url = "github:nix-community/disko";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:Mic92/sops-nix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nur.url = "github:nix-community/NUR";
    nixvim.url = "github:nix-community/nixvim";
    stylix.url = "github:nix-community/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    # Supported systems
    supportedSystems = ["x86_64-linux"];

    # Helper to generate per-system attributes
    eachSystem = nixpkgs.lib.genAttrs supportedSystems;

    # Package set with overlays and config
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.nur.overlays.default
        ];
      };

    mkFormatter = system:
      import ./formatter.nix {
        inherit self;
        pkgs = mkPkgs system;
      };
  in {
    nixosConfigurations.c0d3h01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules/nixos
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.c0d3h01.imports = [./modules/home];
          };
        }
      ];
    };

    homeConfigurations.c0d3h01 = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "x86_64-linux";
      modules = [./modules/home];
    };

    devShells = eachSystem (system: {
      default = let
        pkgs = mkPkgs system;
      in
        import ./shell.nix {
          inherit pkgs;
          formatter = (mkFormatter system).formatter;
        };
    });

    formatter = eachSystem (system:
      (mkFormatter system).formatter);

    checks = eachSystem (system: {
      formatting = (mkFormatter system).check;
    });
  };
}
