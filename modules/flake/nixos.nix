{
  config,
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  hosts = import ../hosts;
  homeModule = self + /modules/home/home.nix;

  # Find the primary user for a host (the one with isMainUser = true)
  mainUser = hostCfg: let
    found =
      builtins.filter
      (name: hostCfg.users.${name}.isMainUser or false)
      (builtins.attrNames hostCfg.users);
  in
    builtins.head found;

  # Build easy-hosts entry from our flat registry
  mkEasyHost = hostName: hostCfg: let
    primary = mainUser hostCfg;
    userCfg = hostCfg.users.${primary};
  in {
    arch = builtins.head (lib.splitString "-" hostCfg.system);
    class = "nixos";
    path = builtins.head hostCfg.modules;
    specialArgs.hostConfig =
      {
        hostname = hostName;
        username = primary;
        inherit (hostCfg) system bootloader;
      }
      // userCfg;
  };
in {
  imports = [
    # keep-sorted start
    inputs.easy-hosts.flakeModule
    # keep-sorted end
  ];

  easy-hosts = {
    shared.modules = [
      (self + /modules/nixos)
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [config.flake.overlays.default];
      }
      (
        {hostConfig, ...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit inputs self;
              userConfig =
                hostConfig
                // {
                  inherit (hostConfig) username hostname system;
                };
            };
            users.${hostConfig.username}.imports = [
              # keep-sorted start
              homeModule
              # keep-sorted end
            ];
          };
        }
      )
    ];

    hosts = builtins.mapAttrs mkEasyHost hosts;
  };
}
