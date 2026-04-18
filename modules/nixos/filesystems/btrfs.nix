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

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nix-boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {device = "/dev/disk/by-label/nix-swap";}
  ];
}
