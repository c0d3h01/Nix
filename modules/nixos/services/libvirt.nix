{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.services.libvirt;
in {
  options.dotfiles.nixos.services.libvirt.enable = mkEnableOption "libvirt and virt-manager";

  config = mkIf cfg.enable {
    programs.virt-manager.enable = true;
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.package = pkgs.qemu_kvm;
        onBoot = "ignore";
        onShutdown = "suspend";
      };
    };
  };
}
