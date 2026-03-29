{
  lib,
  hardwareProfile,
  ...
}: let
  inherit (lib) mkDefault;
  zramSize = "ram * ${toString hardwareProfile.zramMultiplier}";
in {
  # ZRAM Configuration - Aggressive memory compression for low-RAM systems
  # Creates a compressed swap device in RAM to extend available memory
  services.zram-generator = {
    enable = true;
    settings = {
      zram0 = {
        # ZSTD offers excellent compression ratio with good speed
        compression-algorithm = "zstd";
        fs-type = "swap";
        swap-priority = mkDefault hardwareProfile.swapPriority;
        zram-size = zramSize;
        # Memory limit to prevent OOM during heavy compression
        memory-limit = null;
      };
    };
  };

  # Additional sysctl tuning for memory management
  boot.kernel.sysctl = {
    # Allow overcommit for better memory utilization with zram
    "vm.overcommit_memory" = 1;
    # Reduce swappiness to prefer keeping active pages in RAM
    "vm.swappiness" = 60;
    # Watermark scale factor for low-memory situations
    "vm.watermark_scale_factor" = 500;
    # Enable transparent hugepages for performance
    "vm.transparent_hugepage" = "madvise";
  };
}
