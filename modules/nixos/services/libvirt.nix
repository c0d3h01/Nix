{pkgs, ...}: {
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
