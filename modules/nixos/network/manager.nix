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
    dhcpcd.enable = mkForce false;

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
        macAddress = "random";
        scanRandMacAddress = true;
      };
    };
  };
}
