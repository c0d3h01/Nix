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
    initrd = {
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
      systemd.enable = true;
      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];
    };

    kernelModules = lib.mkMerge [
      (lib.mkIf (config.hardware.cpu.amd.updateMicrocode or false) ["kvm-amd"])
      (lib.mkIf (config.hardware.cpu.intel.updateMicrocode or false) ["kvm-intel"])
    ];

    kernelParams = lib.mkDefault [
      "mitigations=off"
    ];

    tmp = {
      useTmpfs = true;
      tmpfsSize = "60%";
      tmpfsHugeMemoryPages = "within_size";
    };

    supportedFilesystems = ["ntfs" "exfat" "vfat"];
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
