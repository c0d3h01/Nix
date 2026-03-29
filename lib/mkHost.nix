# mkHost: produces { nixos, home, meta } from a single host definition
{
  inputs,
  self,
  scx ? null,
}: {
  hostname,
  username,
  fullName,
  system ? "x86_64-linux",
  isNixOS ? true,
  bootloader ? "systemd",
  windowManager ? "gnome",
  workstation ? true,
  stateVersion ? "25.11",
  hardwareProfile ? "amd-ryzen-lowram",
  nixosModules ? [],
  homeModules ? [],
}: let
  inherit (inputs.nixpkgs) lib;

  # Overlays for custom package modifications
  overlays = [
    inputs.nur.overlays.default
  ];

  # Host configuration passed to all modules
  hostConfig = {
    inherit
      hostname
      username
      fullName
      system
      isNixOS
      bootloader
      windowManager
      workstation
      stateVersion
      hardwareProfile
      ;
  };

  # Common special arguments for NixOS and Home Manager
  commonSpecialArgs = {
    inherit inputs self hostConfig scx;
  };

  # Home Manager module path
  homeModulePath = self + /modules/home;

  # Standalone package set for Home Manager (non-NixOS systems)
  pkgsStandalone = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
    inherit overlays;
  };
in {
  # NixOS system configuration
  nixos = lib.nixosSystem {
    inherit system;
    specialArgs = commonSpecialArgs;
    modules =
      [
        {
          nixpkgs.overlays = overlays;
          networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" hostname);
        }

        # Core NixOS modules
        (self + /modules/nixos)

        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = commonSpecialArgs;
            users.${username}.imports = [homeModulePath] ++ homeModules;
          };
        }
      ]
      ++ nixosModules;
  };

  # Standalone Home Manager configuration
  home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsStandalone;
    extraSpecialArgs = commonSpecialArgs;
    modules = [homeModulePath] ++ homeModules;
  };

  # Metadata for reference
  meta = {inherit hostname username;};
}
