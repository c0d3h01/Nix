{
  lib,
  pkgs,
  config,
  ...
}: {
  # Use schedutil governor for dynamic frequency scaling
  # powerManagement.cpuFreqGovernor = "schedutil";

  # Dynamically tunes kernel BPF parameters for network and latency optimization
  # services.bpftune.enable = true;

  # Distributes hardware interrupts across CPU cores to reduce latency spikes
  # services.irqbalance.enable = true;

  # Power management settings
  services.upower = {
    enable = true;
    percentageLow = 25;
    percentageCritical = 20;
    percentageAction = 15;
    criticalPowerAction = "Hibernate";
  };

  # CPU Frequency Scaling
  # services.auto-cpufreq = {
  #   enable = true;

  #   settings = {
  #     # Charger (plugged-in)
  #     charger = {
  #       # Use schedutil governor - smooth frequency scaling based on load
  #       governor = "schedutil";

  #       # Allow turbo when needed, but not always
  #       turbo = "auto";

  #       # Let CPU scale frequency based on demand
  #       scaling_min_freq = "400000"; # 400 MHz minimum
  #       scaling_max_freq = "4000000"; # 4 GHz max (adjust for your CPU)

  #       # Energy performance preference
  #       # "balance_performance" = good balance of perf and efficiency
  #       energy_performance_preference = "balance_performance";

  #       # Enable EPP (Energy Performance Preference)
  #       epp = "balance_performance";
  #     };

  #     # Battery fallback (even if rarely used)
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #       scaling_min_freq = "400000";
  #       scaling_max_freq = "2000000"; # Limit to 2 GHz for thermal reasons
  #       energy_performance_preference = "power";
  #     };
  #   };
  # };

  # TLP
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     # Plugged-in settings for low heat
  #     CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
  #     CPU_MIN_PERF_ON_AC = 0;
  #     CPU_MAX_PERF_ON_AC = 80;  # Limit to 80% for lower heat
  #
  #     # Thermal throttling
  #     CPU_BOOST_ON_AC = 1;
  #     CPU_HWP_DYN_BOOST_ON_AC = 1;
  #
  #     # PCIe ASPM
  #     PCIE_ASPM_ON_AC = "powersupersave";
  #
  #     # USB autosuspend
  #     USB_AUTOSUSPEND = 1;
  #     USB_SUSPEND_ON_START = 1;
  #   };
  # };
}
