# mkHost: produces { nixos, home, meta } from a single host definition
{
  inputs,
  self,
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
  nixosModules ? [],
  homeModules ? [],
}: let
  inherit (inputs.nixpkgs) lib;

  baseOverlays = [
    inputs.nixgl.overlays.default
    inputs.nix-openclaw.overlays.default
    inputs.nur.overlays.default
  ];

  nixglWrapperOverlay = import ../overlays/nixgl-wrapper.nix {inherit isNixOS;};

  allOverlays = baseOverlays ++ [nixglWrapperOverlay];

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
      ;
  };

  commonSpecialArgs = {
    inherit inputs self hostConfig;
  };

  homeModulePath = self + /modules/home;

  pkgsStandalone = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
    overlays = allOverlays;
  };
in {
  nixos = lib.nixosSystem {
    inherit system;
    specialArgs = commonSpecialArgs;
    modules =
      [
        {
          nixpkgs.overlays = allOverlays;
          networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" hostname);
        }

        (self + /modules/nixos)

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

  home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsStandalone;
    extraSpecialArgs = commonSpecialArgs;
    modules = [homeModulePath] ++ homeModules;
  };

  meta = {inherit hostname username;};
}
