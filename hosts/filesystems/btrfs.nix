{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "noatime"
      "compress=zstd:3"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "noatime"
      "compress=zstd:3"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nix-boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # fileSystems."/nix" = {
  #   device = "/dev/disk/by-label/nix-root";
  #   fsType = "btrfs";
  #   options = [
  #     "subvol=/@nix"
  #     "noatime"
  #     "compress=zstd:1"
  #   ];
  # };

  # fileSystems."/var/tmp" = {
  #   device = "/dev/disk/by-label/nix-root";
  #   fsType = "btrfs";
  #   options = [
  #     "subvol=/@/var/tmp"
  #     "noatime"
  #     "compress=zstd:1"
  #   ];
  # };

  # fileSystems."/var/log" = {
  #   device = "/dev/disk/by-label/nix-root";
  #   fsType = "btrfs";
  #   neededForBoot = true;
  #   options = [
  #     "subvol=/@/var/tmp"
  #     "noatime"
  #     "compress=zstd:1"
  #   ];
  # };

  # swapDevices = [
  #   {device = "/dev/disk/by-label/nix-swap";}
  # ];
}
