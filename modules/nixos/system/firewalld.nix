{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.dotfiles.nixos.system.firewalld;
in {
  options.dotfiles.nixos.system.firewalld.enable = mkEnableOption "Firewalld with nftables backend";

  config = mkIf cfg.enable {
    networking = {
      nftables.enable = true;

      firewall = {
        backend = "firewalld";
        checkReversePath = mkForce "loose";
        logRefusedConnections = false;
        logReversePathDrops = true;

        allowedTCPPorts = [
          22
          80
          443
          8080
          59010
          59011
        ];

        allowedUDPPorts = [
          59010
          59011
        ];
      };
    };

    services.firewalld = {
      enable = true;
      package = pkgs.firewalld-gui;
      settings.FirewallBackend = "nftables";
    };
  };
}
