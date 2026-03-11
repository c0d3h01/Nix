{
  config,
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.system.printing;
in {
  options.dotfiles.nixos.system.printing.enable = mkEnableOption "CUPS printing and Avahi";

  config = mkIf cfg.enable {
    services = mkIf hostProfile.isWorkstation {
      printing = {
        enable = false;
        openFirewall = true;
      };

      avahi = {
        enable = false;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
      };
    };
  };
}
