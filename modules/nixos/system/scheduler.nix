{
  lib,
  hostProfile,
  ...
}: let
  inherit (hostProfile) isWorkstation;
in
  lib.mkMerge [
    {
      services.irqbalance.enable = lib.mkDefault isWorkstation;

      services.scx = {
        enable = isWorkstation;
        scheduler = lib.mkDefault "scx_lavd";
        extraArgs = lib.mkDefault [
          "--performance"
        ];
      };
    }

    (lib.mkIf isWorkstation {
      systemd.services.scx.serviceConfig.RestartSec = lib.mkDefault 1;
    })
  ]
