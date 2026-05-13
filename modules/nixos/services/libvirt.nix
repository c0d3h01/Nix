{pkgs, ...}: {
  programs.virt-manager.enable = true;

  virtualisation = {
    waydroid.enable = false;

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
      onBoot = "ignore";
      onShutdown = "suspend";
    };
  };
}
