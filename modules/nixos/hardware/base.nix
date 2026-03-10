{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 0;
    tmp.cleanOnBoot = true;

    initrd = {
      verbose = false;
      systemd.enable = true;
      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];

      supportedFilesystems = ["ntfs" "exfat" "vfat" "zfs"];

      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usb_storage"
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

    kernelModules = lib.mkMerge [
      (lib.mkIf (config.hardware.cpu.amd.updateMicrocode or false) ["kvm-amd"])
      (lib.mkIf (config.hardware.cpu.intel.updateMicrocode or false) ["kvm-intel"])
    ];

    kernelParams = [
      "mitigations=off"
      "quiet"
    ];
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault true;
    enableRedistributableFirmware = true;
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.fwupd = {
    enable = true;
    daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
  };

  hardware.acpilight.enable = true;
}
