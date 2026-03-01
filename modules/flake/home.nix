{
  config,
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  hosts = import ../hosts;
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

  # Build one homeConfiguration per user across all hosts
  mkAllHomeConfigs = let
    perHost = hostName: hostCfg:
      lib.mapAttrsToList (
        userName: userCfg:
          lib.nameValuePair "${userName}@${hostName}" (
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = mkPkgs hostCfg.system;
              extraSpecialArgs = {
                inherit inputs self;
                userConfig =
                  userCfg
                  // {
                    username = userName;
                    hostname = hostName;
                    inherit (hostCfg) system;
                  };
              };
              modules = [homeModule];
            }
          )
      )
      hostCfg.users;
  in
    builtins.listToAttrs (
      builtins.concatLists (
        lib.mapAttrsToList perHost hosts
      )
    );
in {
  imports = [
    # keep-sorted start
    inputs.home-manager.flakeModules.home-manager
    # keep-sorted end
  ];

  flake = {
    homeModules.default = homeModule;
    homeConfigurations = mkAllHomeConfigs;
  };
}
