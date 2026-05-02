{pkgs, ...}: {
  # Enable nftables and keep iptables tooling available.
  networking.nftables.enable = true;
  environment.systemPackages = [pkgs.iptables];
}
