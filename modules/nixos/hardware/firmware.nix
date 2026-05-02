{config, ...}: {
  # Enable fwupd and point it at the configured EFI system partition.

  services.fwupd = {
    enable = true;
    daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
  };
}
