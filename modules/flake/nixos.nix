{
  config,
  inputs,
  self,
  ...
}: let
  hosts = import ../hosts/hosts.nix;
  homeModule = self + /modules/home/home.nix;
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
        {
          hostName,
          userConfig,
          ...
        }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit
                hostName
                inputs
                self
                userConfig
                ;
            };
            users.${userConfig.username}.imports = [
              # keep-sorted start
              homeModule
              # keep-sorted end
            ];
          };
        }
      )
    ];

    hosts = hosts.easyHosts;
  };
}
