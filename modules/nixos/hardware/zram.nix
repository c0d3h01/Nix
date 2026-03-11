{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.hardware.zram;
in {
  options.dotfiles.nixos.hardware.zram.enable = mkEnableOption "zram swap generator";

  config = mkIf cfg.enable {
    services.zram-generator = {
      enable = true;
      settings = {
        zram0 = {
          compression-algorithm = "lz4";
          fs-type = "swap";
          swap-priority = 100;
          zram-size = "ram * 2";
        };
      };
    };
  };
}
