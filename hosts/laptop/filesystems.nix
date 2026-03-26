_: let
  rootDev = "/dev/disk/by-label/nixos-root";
  btrfsOpts = [
    "noatime"
    "compress=zstd:1"
    "ssd"
    "space_cache=v2"
    "discard=async"
  ];
in {
  fileSystems = {
    "/" = {
      device = rootDev;
      fsType = "btrfs";
      options = ["subvol=/@"] ++ btrfsOpts;
    };
    "/home" = {
      device = rootDev;
      fsType = "btrfs";
      options = ["subvol=/@home"] ++ btrfsOpts;
    };
    "/nix" = {
      device = rootDev;
      fsType = "btrfs";
      options = ["subvol=/@nix"] ++ btrfsOpts;
    };
    "/var/tmp" = {
      device = rootDev;
      fsType = "btrfs";
      options = ["subvol=/@tmp"] ++ btrfsOpts;
    };
    "/var/log" = {
      device = rootDev;
      fsType = "btrfs";
      neededForBoot = true;
      options = ["subvol=/@log"] ++ btrfsOpts;
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = ["umask=0077"];
    };
  };
}
