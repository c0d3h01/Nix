{config, ...}: {
  # Weekly discard and Btrfs scrub maintenance.

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.btrfs.autoScrub = {
    enable = config.boot.supportedFilesystems.btrfs or false;
    interval = "weekly";
    fileSystems = ["/"];
  };
}
