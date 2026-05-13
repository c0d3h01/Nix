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
    initrd = {
      verbose = false;
      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];

      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "sd_mod"
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
