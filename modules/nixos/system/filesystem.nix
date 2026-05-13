{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [ "subvol=@var" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIX-BOOT";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nix-root";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
}
