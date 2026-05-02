{pkgs, ...}: {
  # Pin the system kernel package set.

  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
