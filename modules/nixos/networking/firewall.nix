{
  lib,
  pkgs,
  ...
}: {
  networking = {
    firewall = {
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
      backend = "firewalld";
      checkReversePath = lib.mkForce "loose";
      logRefusedConnections = false;
      logReversePathDrops = true;
    };
    nftables.enable = true;
  };

  services.firewalld = {
    enable = true;
    package = pkgs.firewalld-gui;
    settings.FirewallBackend = "nftables";
  };
}
