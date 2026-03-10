{
  lib,
  pkgs,
  ...
}: {
  networking = {
    nftables.enable = true;

    firewall = {
      backend = "firewalld";
      checkReversePath = lib.mkForce "loose";
      logRefusedConnections = false;
      logReversePathDrops = true;

      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        8080 # dev server
        59010 # custom
        59011 # custom
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
}
