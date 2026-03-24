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

  services.fstrim.enable = mkDefault true;

  services.btrfs.autoScrub = mkIf isBtrfs {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };
}
