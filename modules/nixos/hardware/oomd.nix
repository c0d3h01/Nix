{
  lib,
  hardwareProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  # systemd-oomd Configuration - Out-of-memory daemon for proactive memory management
  # Prevents system freezes by killing memory-hungry processes before complete exhaustion
  systemd = {
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;

      # Tuned for low-RAM systems (6GB): React faster at lower pressure threshold
      settings.OOM = {
        # Kill processes when memory pressure exceeds this threshold
        DefaultMemoryPressureLimit = hardwareProfile.oomdPressure;
        # Time window to measure pressure (shorter = more responsive)
        DefaultMemoryPressureDurationSec = hardwareProfile.oomdDuration;
        # Swap usage limit before triggering OOM
        DefaultSwapUsedLimit = "90%";
        # Preferred pressure limit for user slices
        PreferredMemoryPressureLimit = "95%";
      };
    };

    # OOM Score adjustments to protect critical services
    services = {
      # Protect the kernel and init system from being killed
      systemd-journald.serviceConfig.OOMScoreAdjust = -1000;
      systemd-udevd.serviceConfig.OOMScoreAdjust = -1000;
      systemd-logind.serviceConfig.OOMScoreAdjust = -900;

      # Make display manager harder to kill than apps but easier than kernel
      "gdm.service".serviceConfig.OOMScoreAdjust = mkIf (hardwareProfile.gpuType != null) (-500);
      "sddm.service".serviceConfig.OOMScoreAdjust = mkIf (hardwareProfile.gpuType != null) (-500);

      # Nix builds are memory-intensive; allow them to be killed first
      nix-daemon.serviceConfig.OOMScoreAdjust = 500;

      # Database services should be protected
      postgresql.serviceConfig.OOMScoreAdjust = -300;
    };
  };
}
