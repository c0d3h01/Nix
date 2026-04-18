{pkgs, ...}: {
  users.users.c0d3h01.extraGroups = [
    "plugdev" # USB devices (Android, Microcontrollers)
    "adbusers" # Android Debug Bridge
    "libvirtd" # KVM/QEMU virtualization access
  ];

  programs.virt-manager.enable = true;

  virtualisation = {
    waydroid.enable = true;

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
      onBoot = "ignore";
      onShutdown = "suspend";
    };
  };
}
