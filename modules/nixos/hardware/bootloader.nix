{
  # GRUB bootloader for UEFI systems.

  boot.loader = {
    timeout = 5;
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"];
      configurationLimit = 20;
      efiInstallAsRemovable = false;
      useOSProber = false;
    };
  };
}
