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

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    system = "x86_64-linux";

    mkPkgs = sys:
      import nixpkgs {
        system = sys;
        config.allowUnfree = true;
        overlays = [inputs.nur.overlays.default];
      };

    eachSystem = f: lib.genAttrs (import systems) f;

    specialArgs = {inherit inputs self system;};
  in {
    nixosConfigurations.default = lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nixos
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = specialArgs;
            users."c0d3h01".imports = [./modules/home];
          };
        }
      ];
    };

    homeConfigurations.default = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = specialArgs;
      modules = [./modules/home];
    };

    devShells = eachSystem (sys: {
      default = import ./shell.nix {
        pkgs = mkPkgs sys;
        inherit
          ((import ./formatter.nix {
            inherit self;
            pkgs = mkPkgs sys;
          }))
          formatter
          ;
      };
    });

    formatter = eachSystem (
      sys:
        (import ./formatter.nix {
          inherit self;
          pkgs = mkPkgs sys;
        }).formatter
    );

    checks = eachSystem (sys: {
      formatting =
        (import ./formatter.nix {
          inherit self;
          pkgs = mkPkgs sys;
        }).check;
    });

    packages = eachSystem (sys: import ./scripts.nix {pkgs = mkPkgs sys;});
  };
}
