{
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf hostProfile.isWorkstation {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          KernelExperimental = "true";
          FastIdleTimeout = "1";
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    systemd.services.bluetooth.serviceConfig.Restart = "on-failure";
  };
}
