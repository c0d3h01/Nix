{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.zoxide;
in {
  options.dotfiles.home.shell.zoxide.enable = mkEnableOption "zoxide directory jumper";

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
