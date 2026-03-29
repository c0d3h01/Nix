{
  lib,
  pkgs,
  hostProfile,
  hardwareProfile,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  isAmd = hardwareProfile.cpuVendor == "amd";
in {
  config = mkIf isAmd {
    # AMD GPU & CPU Configuration
    hardware.graphics = mkIf hostProfile.isWorkstation {
      enable = mkDefault true;
      extraPackages = with pkgs; [
        mesa
        libva-vdpau-driver
        vaapiVdpau
        libvdpau-va-gl
      ];

      enable32Bit = mkDefault true;
      extraPackages32 = with pkgs.driversi686Linux; [
        mesa
      ];
    };

    # Load amdgpu in initrd: fixes Plymouth KMS, eliminates low-res flicker,
    # and ensures the GPU is ready before any DRM consumer starts.
    hardware.amdgpu.initrd.enable = true;

    # Use the open-source amdgpu driver for X11/Wayland
    services.xserver.videoDrivers = mkDefault ["amdgpu"];

    # AMD CPU Microcode - critical for security and stability
    hardware.cpu.amd.updateMicrocode = mkDefault true;

    # Power management: Use schedutil governor for dynamic frequency scaling
    powerManagement.cpuFreqGovernor = "schedutil";

    # Enable ROCm OpenCL for compute workloads (optional, uncomment if needed)
    # hardware.amdgpu.opencl.enable = mkDefault true;
  };
}
