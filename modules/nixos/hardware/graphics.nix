{
  lib,
  pkgs,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in {
  config = mkIf hostProfile.isWorkstation {
    hardware.graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault true;

      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };

    services.xserver.videoDrivers = mkDefault ["amdgpu"];
    hardware.amdgpu.opencl.enable = mkDefault true;
  };
}
