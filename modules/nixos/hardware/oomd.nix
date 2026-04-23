{
  systemd = {
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;

      settings.OOM = {
        DefaultMemoryPressureLimit = "60%";
        DefaultMemoryPressureDurationSec = "3s";
        DefaultSwapUsedLimit = "90%";
        PreferredMemoryPressureLimit = "95%";
      };
    };
  };
}
