{
  config,
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkMerge mkDefault;
  inherit (hostProfile) isWorkstation;
  cfg = config.dotfiles.nixos.system.scheduler;
in {
  options.dotfiles.nixos.system.scheduler.enable = mkEnableOption "scx and irqbalance schedulers";

  config = mkIf cfg.enable (mkMerge [
    {
      services.irqbalance.enable = mkDefault isWorkstation;

      services.scx = {
        enable = isWorkstation;
        scheduler = mkDefault "scx_lavd";
        extraArgs = mkDefault [
          "--autopilot"
        ];
      };
    }

    (mkIf isWorkstation {
      systemd.services.scx.serviceConfig.RestartSec = mkDefault 1;
    })
  ]);
}
