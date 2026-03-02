# Networking — NetworkManager with systemd-resolved DNS
{lib, ...}: {
  # systemd-resolved for DNS caching and DNS-over-TLS
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    # DNS-over-TLS for privacy — falls back to plaintext if unsupported
    dnsovertls = "opportunistic";
    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
    ];
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";

    wifi = {
      # Disable Wi-Fi powersave — prevents latency spikes
      powersave = lib.mkForce false;
      # MAC randomization — privacy hardening
      macAddress = "random";
      scanRandMacAddress = true;
    };

    # Randomize wired MAC too
    ethernet.macAddress = "random";
  };
}
