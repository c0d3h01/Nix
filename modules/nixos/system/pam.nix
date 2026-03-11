{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.system.pam;
in {
  options.dotfiles.nixos.system.pam.enable = mkEnableOption "PAM extra rules including U2F";

  config = mkIf cfg.enable {
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      ly.u2fAuth = true;
      polkit-1.u2fAuth = true;
    };
  };
}
