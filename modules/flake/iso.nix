{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  hosts = import ../hosts;

  mkIso = {
    system,
    hostName,
    hostCfg,
  }: let
    mainUser = builtins.head (
      builtins.filter
      (name: hostCfg.users.${name}.isMainUser or false)
      (builtins.attrNames hostCfg.users)
    );
    userCfg = hostCfg.users.${mainUser};
  in
    (lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostName inputs self;
        hostConfig =
          {
            hostname = hostName;
            username = mainUser;
            bootloader = "grub"; # ISOs always use GRUB
            inherit (hostCfg) system;
          }
          // userCfg;
      };
      modules = [
        (self + /modules/nixos)
        (builtins.head hostCfg.modules)
        inputs.disko.nixosModules.disko
        (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix")
        {
          networking.hostName = lib.mkForce "${hostName}-iso";
          image.baseName = lib.mkForce "dotfiles-${hostName}";
          boot.loader.timeout = lib.mkForce 10;
        }
      ];
    })
    .config
    .system
    .build
    .isoImage;
in {
  perSystem = {system, ...}: let
    hostsForSystem =
      lib.filterAttrs (_: h: h.system == system) hosts;
  in {
    packages =
      lib.mapAttrs' (
        hostName: hostCfg:
          lib.nameValuePair "iso-${hostName}" (mkIso {
            inherit hostName hostCfg system;
          })
      )
      hostsForSystem;
  };
}
