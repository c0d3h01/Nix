{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.dotfiles.nixos.system.oomd;
in {
  options.dotfiles.nixos.system.oomd.enable = mkEnableOption "systemd-oomd out-of-memory daemon";

  config = mkIf cfg.enable {
    systemd.oomd = {
      enable = mkDefault true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
    };

    systemd.services.nix-daemon.serviceConfig = {
      OOMPolicy = "continue";
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "80%";
    };
  };
}
