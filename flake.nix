{
  description = "NixOS Dotfiles - High Performance Developer Workstation";

  inputs = {
    # Core NixOS packages - unstable channel for latest features
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # System type definitions
    systems.url = "github:nix-systems/default";

    # Flake utilities
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # Compatibility layer for non-flake systems
    flake-compat = {
      url = "github:nix-community/flake-compat";
      flake = false;
    };

    # Modular flake framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management with SOPS
    sops = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Spotify customization
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    # Nix User Repository for additional packages
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Neovim configuration framework
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    # Alternative Nix package manager
    lix = {
      url = "git+https://gerrit.lix.systems/lix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    # SCX schedulers for low-latency desktop performance
    scx = {
      url = "github:sched-ext/scx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    scx,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    # Supported system architectures
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = lib.genAttrs supportedSystems;

    # Package set generator with unfree support enabled
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
          permittedInsecurePackages = [];
        };
      };

    # Host builder function
    mkHost = import ./lib/mkHost.nix {inherit inputs self scx;};

    # Host definitions
    hosts = {
      laptop = mkHost {
        hostname = "laptop";
        username = "c0d3h01";
        fullName = "Harshal Sawant";
        system = "x86_64-linux";
        isNixOS = true;
        bootloader = "grub"; # Options: limine, grub, systemd
        windowManager = "gnome"; # Options: xfce, gnome, plasma
        workstation = true;
        stateVersion = "25.11";
        hardwareProfile = "amd-ryzen-lowram"; # amd-ryzen-lowram | intel | amd-ryzen
        nixosModules = [./hosts/laptop];
      };
    };

    # Formatter configuration
    fmtFor = system:
      import ./lib/formatter.nix {
        pkgs = pkgsFor system;
        inherit self;
      };
  in {
    # NixOS system configurations
    nixosConfigurations = lib.mapAttrs (_: h: h.nixos) hosts;

    # Home Manager user configurations
    homeConfigurations =
      lib.mapAttrs' (
        name: h:
          lib.nameValuePair "${h.meta.username}@${name}" h.home
      )
      hosts;

    # Custom overlays for package modifications
    overlays = import ./overlays {inherit inputs;};

    # Development shells for each system
    devShells = forAllSystems (system: {
      default = import ./lib/shell.nix {
        pkgs = pkgsFor system;
        inherit ((fmtFor system)) formatter;
      };
    });

    # Code formatters for each system
    formatter = forAllSystems (system: (fmtFor system).formatter);

    # CI/CD checks
    checks = forAllSystems (system: {
      formatting = (fmtFor system).check;
    });

    # Utility packages and scripts
    packages = forAllSystems (system: import ./lib/scripts.nix {pkgs = pkgsFor system;});
  };
}
