{
  lib,
  hostProfile,
  ...
}: let
  selected = hostProfile.bootloader;
in {
  boot.loader.systemd-boot = lib.mkIf (selected == "systemd") {
    enable = true;
    configurationLimit = 15;
    editor = false;
  };
}
