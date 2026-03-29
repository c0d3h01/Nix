{
  config,
  lib,
  hostProfile,
  scx ? null,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf hostProfile.isWorkstation {
    services = {
      # Dynamically tunes kernel BPF parameters for network and latency optimization
      bpftune.enable = true;

      # Distributes hardware interrupts across CPU cores to reduce latency spikes
      irqbalance.enable = true;

      # Power management for laptops
      upower = {
        enable = true;
        percentageLow = 25;
        percentageCritical = 20;
        percentageAction = 15;
        criticalPowerAction = "Hibernate";
      };

      # SCX (Sched Ext) - Modern Linux scheduler framework for low-latency desktop
      # Only enabled if the scx input is available (requires flake input)
      scx = mkIf (scx != null) {
        enable = true;
        # scx_lavd: Latency-critical, adaptive scheduler optimized for desktops
        scheduler = "scx_lavd";
        extraArgs = [
          # Balance latency and power efficiency
          "--interactive"
          # Limit active cores under light load to save power/heat
          "--active_core_ratio"
          "0.75"
          # Let CPU governor handle frequency scaling
          "--no_freq_scale"
        ];
      };
    };

    # Boot optimization: Reduce boot time by disabling unnecessary services
    boot.bootLoaderSystemsLimit = mkIf (config.boot.loader.grub.enable or false) 15;
  };
}
