{
  lib,
  hostConfig,
  ...
}: let
  hostProfile = {
    isWorkstation = hostConfig.workstation or false;
    windowManager = hostConfig.windowManager or "gnome";
    bootloader = hostConfig.bootloader or "systemd";
  };
in {
  _module.args.hostProfile = hostProfile;

  assertions = [
    {
      assertion = lib.elem hostProfile.windowManager [
        "gnome"
        "kde"
        "xfce"
      ];
      message = "hostConfig.windowManager must be one of: gnome, kde, xfce.";
    }
    {
      assertion = lib.elem hostProfile.bootloader [
        "systemd"
        "limine"
        "grub"
      ];
      message = "hostConfig.bootloader must be one of: systemd, limine, grub.";
    }
  ];

  dotfiles.nixos = {
    hardware.graphics.enable = lib.mkDefault hostProfile.isWorkstation;
    hardware.zram.enable = lib.mkDefault true;
    hardware.udev.enable = lib.mkDefault true;
    hardware.filesystem.enable = lib.mkDefault true;

    services.podman.enable = lib.mkDefault true;
    services.ollama.enable = lib.mkDefault true;
    services.libvirt.enable = lib.mkDefault false;
    services.wireshark.enable = lib.mkDefault true;

    system.audio.enable = lib.mkDefault true;
    system.diff.enable = lib.mkDefault true;
    system.firewalld.enable = lib.mkDefault true;
    system.fonts.enable = lib.mkDefault true;
    system.gnupg.enable = lib.mkDefault true;
    system.nix-ld.enable = lib.mkDefault true;
    system.oomd.enable = lib.mkDefault true;
    system.openssh.enable = lib.mkDefault true;
    system.packages.enable = lib.mkDefault hostProfile.isWorkstation;
    system.pam.enable = lib.mkDefault true;
    system.printing.enable = lib.mkDefault false;
    system.scheduler.enable = lib.mkDefault hostProfile.isWorkstation;
    system.secrets.enable = lib.mkDefault true;
  };
}
