{
  config,
  inputs,
  self,
  ...
}: let
  hosts = import ../hosts/hosts.nix;
  overlay = config.flake.overlays.default;
  homeModule = self + /modules/home/home.nix;

  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = [overlay];
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
    };

  mkHomeConfiguration = hostName: userConfig:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs userConfig.system;
      extraSpecialArgs = {
        inherit
          hostName
          inputs
          self
          userConfig
          ;
      };
      modules = [
        homeModule
      ];
    };
in {
  imports = [
    # keep-sorted start
    inputs.home-manager.flakeModules.home-manager
    # keep-sorted end
  ];

  flake = {
    homeModules.default = homeModule;
    homeConfigurations =
      inputs.nixpkgs.lib.mapAttrs (
        _: homeHost: mkHomeConfiguration homeHost.hostName homeHost.userConfig
      )
      hosts.home;
  };
}
