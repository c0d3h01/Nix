{
  config,
  lib,
  pkgs,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.dotfiles.nixos.hardware.graphics;
in {
  options.dotfiles.nixos.hardware.graphics.enable = mkEnableOption "Graphics support";

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault hostProfile.isWorkstation;

      extraPackages = mkIf hostProfile.isWorkstation (with pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
      ]);
    };

    services.xserver.videoDrivers = mkDefault ["amdgpu"];
    hardware.amdgpu.opencl.enable = mkDefault true;
  };
}
