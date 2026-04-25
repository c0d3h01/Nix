{pkgs, ...}: {
  # 🤯️ Use nftables as the backend for better performance and lower overhead
  networking.nftables.enable = true;
  environment.systemPackages = [ pkgs.iptables ];
}
