{
  config,
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf hostProfile.isWorkstation {
    # Use schedutil governor for dynamic frequency scaling
    # powerManagement.cpuFreqGovernor = "schedutil";

    services = {
      # Dynamically tunes kernel BPF parameters for network and latency optimization
      bpftune.enable = false;

      # Distributes hardware interrupts across CPU cores to reduce latency spikes
      irqbalance.enable = true;

      upower = {
        enable = true;
        percentageLow = 25; # Warn user when battery drops below 25%
        percentageCritical = 20; # Trigger critical warning at 20%
        percentageAction = 15; # Execute action when battery hits 15%
        criticalPowerAction = "Hibernate"; # Hibernate system at 15% battery
      };

      scx = {
        # Enable SCX only on workstations.
        enable = true;
        scheduler = "scx_bpfland";
      };
    };
  };
}
