{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.services.podman;
in {
  options.dotfiles.nixos.services.podman.enable = mkEnableOption "Podman container engine";

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;

      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all" "--volumes"];
      };
    };

    users.users.${hostConfig.username} = {
      autoSubUidGidRange = true;
    };

    environment.systemPackages = with pkgs; [
      podman-desktop
      podman-compose
      docker-buildx
      skopeo
    ];
  };
}
