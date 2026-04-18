{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkForce;
in {
  environment.systemPackages = [
    pkgs.networkmanagerapplet
  ];

  networking = {
    # DHCP has been deprecated; use networkd instead
    useDHCP = mkForce false;
    useNetworkd = mkForce true;

    # Use predictable interface names (e.g., wlp3s0) for stable rules
    usePredictableInterfaceNames = true;

    # Enable IPv6 for modern connectivity
    enableIPv6 = true;

    # Cloudflare + Google DNS
    nameservers = mkDefault [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      unmanaged = [
        "interface-name:docker*"
        "interface-name:waydroid*"
      ];

      wifi = {
        backend = "wpa_supplicant"; # iwd | wpa_supplicant
        powersave = false;
        # macAddress = "random";
        scanRandMacAddress = true;
      };
    };
  };

  # Kernel TCP optimizations for low latency and better Wi-Fi performance
  boot.kernel.sysctl = {
    # Use BBR congestion control (better for wireless/variable bandwidth)
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Reduce latency for interactive traffic
    "net.ipv4.tcp_low_latency" = 1;

    # Enable TCP Fast Open (reduces connection handshake time)
    "net.ipv4.tcp_fastopen" = 3;

    # Increase buffer sizes for high-throughput bursts
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # Prevent packet drops under load
    "net.core.netdev_max_backlog" = 5000;
  };
}
