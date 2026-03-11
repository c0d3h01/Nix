{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.system.gnupg;
in {
  options.dotfiles.nixos.system.gnupg.enable = mkEnableOption "GnuPG agent support";

  config = mkIf cfg.enable {
    programs.mtr.enable = true;

    programs.gnupg = {
      agent.enable = true;
      agent.enableSSHSupport = true;
    };
  };
}
