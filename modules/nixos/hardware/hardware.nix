{
  config,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib) mkDefault mkIf mkMerge;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  hardware = {
    # Enable all firmware (drivers, microcode, etc.)
    enableAllFirmware = mkDefault true;

    # Allow redistributable firmware (e.g., for Wi-Fi, GPU)
    enableRedistributableFirmware = mkDefault true;

    # Backlight control via ACPI (laptops)
    acpilight.enable = mkDefault true;

    # AMD CPU microcode updates
    cpu.amd.updateMicrocode = mkDefault true;

    # Enable Industrial I/O sensors (temp, light, etc.)
    sensor.iio.enable = mkDefault true;
  };

  boot = {
    tmp.cleanOnBoot = true;

    extraModulePackages = [ linuxPackages_latest.rtw88 ];

    initrd = {
      verbose = true;

      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];

      supportedFilesystems = [
        "btrfs"
        "ext4"
        "ntfs"
        "exfat"
        "vfat"
        "xfs"
      ];

      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];

      kernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "btrfs"
        "sd_mod"
        "dm_mod"
      ];
    };

    kernelModules = [
      "kvm-amd"
    ];
  };
}
