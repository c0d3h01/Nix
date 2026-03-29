{
  lib,
  hostProfile,
  ...
}: let
  selected = hostProfile.bootloader;
in {
  boot.loader.grub = lib.mkIf (selected == "grub") {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 15;
    efiInstallAsRemovable = false;
    useOSProber = true;
  };
}
