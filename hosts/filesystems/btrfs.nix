{
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nix-boot";
    fsType = "vfat";
    options = ["umask=0077"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=/@"
      "noatime"
      "compress=zstd:1"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=/@"
      "noatime"
      "compress=zstd:1"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=/@"
      "noatime"
      "compress=zstd:1"
    ];
  };

  fileSystems."/var/tmp" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [
      "subvol=/@"
      "noatime"
      "compress=zstd:1"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=/@"
      "noatime"
      "compress=zstd:1"
    ];
  };
}
