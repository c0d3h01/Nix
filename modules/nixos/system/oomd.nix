{
  systemd = {
    oomd = {
      enable = false;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;

      settings.OOM = {
        # More conservative thresholds to prevent thrashing
        DefaultMemoryPressureLimit = "70%"; # Was 60% - less aggressive
        DefaultMemoryPressureDurationSec = "5s"; # Was 3s - give processes time to recover
        DefaultSwapUsedLimit = "95%"; # Was 90% - allow more swap usage
        PreferredMemoryPressureLimit = "90%"; # Was 95% - act before critical

        # Additional fine-tuning
        DefaultMemPressureDurationSec = "5s";
        DefaultLowSwapPressureDurationSec = "30s";
      };
    };
  };
}
