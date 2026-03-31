{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

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
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    # Instantiate pkgs for a given system with shared config.
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [inputs.nur.overlays.default];
      };

    # eachSystem replaces flake-utils.lib.eachDefaultSystem using the
    eachSystem = f:
      lib.genAttrs (import systems) f;

    mkHost = import ./lib/mkHost.nix {inherit inputs self;};

    # Host definitions
    hosts = {
      firus = mkHost {
        hostname = "firus";
        username = "c0d3h01";
        fullName = "Harshal Sawant";
        system = "x86_64-linux";
        bootloader = "grub";
        windowManager = "gnome";
        stateVersion = "25.11";
        nixosModules = [./hosts/firus];
      };
    };
  in {
    # NixOS systems
    nixosConfigurations =
      lib.filterAttrs (_: v: v != null)
      (lib.mapAttrs (_: h: h.nixos) hosts);

    # Standalone Home Manager configurations.
    homeConfigurations =
      lib.mapAttrs' (
        _: h: lib.nameValuePair "${h.meta.username}@${h.meta.hostname}" h.home
      )
      hosts;

    # Dev tools
    devShells = eachSystem (system: {
      default = import ./lib/shell.nix {
        pkgs = mkPkgs system;
        inherit
          ((import ./lib/formatter.nix {
            inherit self;
            pkgs = mkPkgs system;
          }))
          formatter
          ;
      };
    });

    formatter = eachSystem (
      system:
        (import ./lib/formatter.nix {
          inherit self;
          pkgs = mkPkgs system;
        }).formatter
    );

    checks = eachSystem (system: {
      formatting =
        (import ./lib/formatter.nix {
          inherit self;
          pkgs = mkPkgs system;
        }).check;
    });

    packages = eachSystem (
      system:
        import ./lib/scripts.nix {pkgs = mkPkgs system;}
    );
  };
}
