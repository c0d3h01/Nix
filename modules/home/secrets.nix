{
  config,
  lib,
  inputs,
  self,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.secrets;
in {
  options.dotfiles.home.secrets.enable = mkEnableOption "SOPS secrets management";

  imports = [
    inputs.sops.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${self}/secrets/default.yaml";
      age.sshKeyPaths = [
        "${config.home.homeDirectory}/.ssh/id_ed25519"
      ];
    };
  };
}
