{
  description = "NixOS Dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Just for pinning
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-compat = {
      url = "github:nix-community/flake-compat";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    lix = {
      url = "git+https://gerrit.lix.systems/lix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = lib.genAttrs supportedSystems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    mkHost = import ./lib/mkHost.nix {inherit inputs self;};

    hosts = {
      laptop = mkHost {
        hostname = "laptop";
        username = "c0d3h01";
        fullName = "Harshal Sawant";
        system = "x86_64-linux";
        isNixOS = true;
        bootloader = "grub"; # limine | grub | systemd
        windowManager = "gnome"; # xfce | gnome | plasma
        workstation = true;
        stateVersion = "25.11";
        nixosModules = [./hosts/laptop];
      };
    };

    fmtFor = system:
      import ./lib/formatter.nix {
        pkgs = pkgsFor system;
        inherit self;
      };
  in {
    nixosConfigurations = lib.mapAttrs (_: h: h.nixos) hosts;

    homeConfigurations =
      lib.mapAttrs' (
        name: h:
          lib.nameValuePair "${h.meta.username}@${name}" h.home
      )
      hosts;

    overlays = import ./overlays {inherit inputs;};

    devShells = forAllSystems (system: {
      default = import ./lib/shell.nix {
        pkgs = pkgsFor system;
        inherit ((fmtFor system)) formatter;
      };
    });

    formatter = forAllSystems (system: (fmtFor system).formatter);

    checks = forAllSystems (system: {
      formatting = (fmtFor system).check;
    });

    packages = forAllSystems (system: import ./lib/scripts.nix {pkgs = pkgsFor system;});
  };
}
