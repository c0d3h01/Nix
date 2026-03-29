{pkgs, ...}: {
  networking.nftables.enable = true;

  networking.firewall = {
    backend = "firewalld";
    checkReversePath = "loose";
    logRefusedConnections = false;
    logReversePathDrops = true;

    allowedTCPPorts = [22 80 443 8080 59010 59011];
    allowedUDPPorts = [59010 59011];
  };

  services.firewalld = {
    enable = true;
    package = pkgs.firewalld-gui;

    settings = {
      FirewallBackend = "nftables";
      DefaultZone = "public";
      Lockdown = true;
      AllowZoneDrifting = false;
    };
  };
}
