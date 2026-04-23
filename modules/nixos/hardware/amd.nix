{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in {
  # AMD GPU & CPU Configuration
  hardware.graphics = {
    enable = mkDefault true;
    extraPackages = with pkgs; [
      mesa
      libva-vdpau-driver
    ];

    enable32Bit = mkDefault false;
    extraPackages32 = with pkgs.driversi686Linux; [
    ];
  };

  # Load amdgpu in initrd: fixes Plymouth KMS, eliminates low-res flicker,
  # and ensures the GPU is ready before any DRM consumer starts.
  hardware.amdgpu.initrd.enable = true;

  # Enable OpenCL - ROCM only.
  # hardware.amdgpu.opencl.enable = mkDefault true;

  # Use the open-source amdgpu driver
  services.xserver.videoDrivers = mkDefault ["amdgpu"];

  # AMD CPU Microcode
  hardware.cpu.amd.updateMicrocode = mkDefault true;
}
