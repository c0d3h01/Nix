{
  lib,
  hostConfig,
  ...
}: let
  # Hardware profile definitions for different system configurations
  hardwareProfiles = {
    # AMD Ryzen APU with limited RAM (6GB or less)
    # Optimized for memory pressure, aggressive zRAM, conservative builds
    "amd-ryzen-lowram" = {
      cpuVendor = "amd";
      gpuType = "amd-apu";
      ramSize = "low"; # < 8GB
      zramMultiplier = 2;
      maxBuildJobs = 2;
      buildCores = 2;
      oomdPressure = "60%";
      oomdDuration = 3;
      swapPriority = 100;
    };

    # Standard AMD Ryzen desktop/workstation
    "amd-ryzen" = {
      cpuVendor = "amd";
      gpuType = "amd-apu";
      ramSize = "standard"; # 8-16GB
      zramMultiplier = 1.5;
      maxBuildJobs = 4;
      buildCores = 4;
      oomdPressure = "70%";
      oomdDuration = 5;
      swapPriority = 100;
    };

    # Intel systems
    "intel" = {
      cpuVendor = "intel";
      gpuType = "intel-igd";
      ramSize = "standard";
      zramMultiplier = 1.5;
      maxBuildJobs = 4;
      buildCores = 4;
      oomdPressure = "70%";
      oomdDuration = 5;
      swapPriority = 100;
    };
  };

  # Get the selected hardware profile or default to amd-ryzen-lowram
  selectedProfile = hostConfig.hardwareProfile or "amd-ryzen-lowram";
  hardwareProfile = hardwareProfiles.${selectedProfile} or hardwareProfiles."amd-ryzen-lowram";

  # Build hostProfile with all configuration
  hostProfile = {
    isWorkstation = hostConfig.workstation or false;
    windowManager = hostConfig.windowManager or "gnome";
    bootloader = hostConfig.bootloader or "systemd";
    inherit hardwareProfile;
  };
in {
  # Pass hostProfile to all modules
  _module.args.hostProfile = hostProfile;
  _module.args.hardwareProfile = hardwareProfile;

  # Configuration assertions
  assertions = [
    {
      assertion = lib.elem hostProfile.windowManager ["gnome" "plasma" "xfce"];
      message = "hostConfig.windowManager must be one of: gnome, plasma, xfce.";
    }
    {
      assertion = lib.elem hostProfile.bootloader ["systemd" "limine" "grub"];
      message = "hostConfig.bootloader must be one of: systemd, limine, grub.";
    }
    {
      assertion = builtins.hasAttr selectedProfile hardwareProfiles;
      message = "hardwareProfile '${selectedProfile}' is not valid. Available: ${lib.concatStringsSep ", " (builtins.attrNames hardwareProfiles)}";
    }
  ];
}
