{
  # Btrfs layout with a protected EFI partition, compressed subvolumes, and swap.

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIX-BOOT";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = ["subvol=@" "noatime" "compress=zstd:3"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = ["subvol=@home" "noatime" "compress=zstd:3"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = ["subvol=@nix" "noatime" "compress=zstd:3"];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = ["subvol=@var" "noatime" "compress=zstd:3"];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
}
