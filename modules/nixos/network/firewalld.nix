{pkgs, ...}: {
  # firewalld-backed firewall with nftables and a small default allowlist.

  networking.firewall = {
    # Use firewalld as the management interface.
    backend = "firewalld";

    # Allow asymmetric routing used by some dev and VM setups.
    checkReversePath = "loose";

    # Reduce refused-connection noise, but keep reverse-path drop logs.
    logRefusedConnections = false;
    logReversePathDrops = true;

    # Keep shared defaults small; prefer service-specific zone rules.
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
      8080 # Dev servers
      59010 # Custom/App specific
      59011 # Custom/App specific
    ];

    allowedUDPPorts = [
      59010
      59011
    ];
  };

  services.firewalld = {
    enable = true;
    package = pkgs.firewalld-gui;

    settings = {
      # Enforce nftables backend.
      FirewallBackend = "nftables";

      # Standard zone for laptops and workstations.
      DefaultZone = "public";

      # Prevent unauthorized apps from changing firewall rules.
      Lockdown = true;

      AllowZoneDrifting = false;
    };
  };
}
