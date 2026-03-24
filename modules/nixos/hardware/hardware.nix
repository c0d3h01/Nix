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
    enableRedistributableFirmware = true;

    # Backlight control via ACPI (laptops)
    acpilight.enable = true;

    # AMD CPU microcode updates
    cpu.amd.updateMicrocode = mkDefault true;

    # Enable Industrial I/O sensors (temp, light, etc.)
    sensor.iio.enable = mkDefault true;
  };

  # Device mounting and smartcard daemons
  services.udisks2.enable = true;
  services.pcscd.enable = true;

  # Firmware support
  services.fwupd = {
    # Firmware update daemon (for UEFI, Thunderbolt, etc.)
    enable = true;

    # Set ESP location for firmware updates
    daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
  };

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 0;
    tmp.cleanOnBoot = true;

    initrd = {
      verbose = false;
      systemd.enable = true;
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

    kernelModules = mkMerge [
      (mkIf (config.hardware.cpu.amd.updateMicrocode or false) ["kvm-amd"])
      (mkIf (config.hardware.cpu.intel.updateMicrocode or false) ["kvm-intel"])
    ];
  };
}
