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
  in {
    nixosConfigurations = eachSystem (system: {
      c0d3h01 = nixpkgs.lib.nixosSystem {
        inherit system;
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
    });

    homeConfigurations = eachSystem (system: {
      c0d3h01 = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules = [./modules/home];
      };
    });

    devShells = eachSystem (system: {
      default = import ./shell.nix {inherit (mkPkgs system) pkgs;};
    });

    formatter = eachSystem (system: let
    formatter = import ./formatter.nix { inherit self; pkgs = mkPkgs system; };
    in {
      default = formatter.formatter;
    });

    checks = eachSystem (system: let
      formatter = import ./formatter.nix { inherit self; pkgs = mkPkgs system; };
    in {
      formatting = formatter.check;
    });
  };
}
