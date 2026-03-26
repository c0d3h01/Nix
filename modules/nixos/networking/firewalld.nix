{pkgs, ...}: {
  # Use nftables as the backend for better performance and lower overhead
  networking.nftables.enable = true;

  networking.firewall = {
    # Explicitly set firewalld as the management interface
    backend = "firewalld";

    # Security: 'loose' allows asymmetric routing (common in dev/VM setups)
    checkReversePath = "loose";

    # Logging: Disable refused connections to reduce log noise, keep reverse path drops
    logRefusedConnections = false;
    logReversePathDrops = true;

    # Ports: Only essential services.
    # Note: When using firewalld, prefer adding ports via `services.firewalld` zones
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
      # Enforce nftables backend
      FirewallBackend = "nftables";

      # Default Zone: 'public' is standard for laptops/workstations
      DefaultZone = "public";

      # Lockdown: Prevent unauthorized apps from changing firewall rules
      Lockdown = true;

      # Allow Multicast DNS (mDNS) for local network discovery (printers, shares)
      # This is often needed for a good desktop experience
      AllowZoneDrifting = false;
    };
  };
}
