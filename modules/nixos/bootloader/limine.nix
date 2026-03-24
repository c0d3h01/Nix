{
  lib,
  hostProfile,
  ...
}: let
  selected = hostProfile.bootloader;
in {
  boot.loader = lib.mkIf (selected == "limine") {
    grub.enable = lib.mkForce false;
    systemd-boot.enable = lib.mkForce false;

    limine = {
      enable = true;
      efiSupport = true;
      biosSupport = false;
      maxGenerations = 15;
      enableEditor = false;
    };
  };
}
