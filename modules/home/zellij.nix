{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.terminal.zellij;
in {
  options.dotfiles.home.terminal.zellij.enable = mkEnableOption "Zellij terminal workspace";

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      exitShellOnExit = false;
      settings = {
        theme = "solarized-dark";
      };
    };
  };
}
