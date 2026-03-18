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
        enable = true;
        openFirewall = true;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
      };
    };
  };
}
