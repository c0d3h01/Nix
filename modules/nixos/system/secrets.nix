{
  config,
  lib,
  inputs,
  self,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.system.secrets;
in {
  options.dotfiles.nixos.system.secrets.enable = mkEnableOption "sops-nix secrets management";

  imports = [
    inputs.sops.nixosModules.sops
  ];

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${self}/secrets/default.yaml";
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };
}
