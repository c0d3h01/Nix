{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  rootFs = config.fileSystems."/".fsType;
  isBtrfs = rootFs == "btrfs";
in {
  environment.systemPackages = [
    pkgs.btrfs-progs
  ];

  services.fstrim = {
    enable = mkDefault true;
    interval = "weekly";
  };

  services.btrfs.autoScrub = mkIf isBtrfs {
    enable = mkDefault true;
    interval = "monthly";
    fileSystems = ["/"];
  };
}
