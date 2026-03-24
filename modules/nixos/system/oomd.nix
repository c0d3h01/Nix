{lib, ...}: let
  inherit (lib) mkDefault;
in {
  systemd = {
    # Systemd OOMd
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
      settings.OOM.DefaultMemoryPressureDurationSec = "20s";
    };

    services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 350;
  };
}
