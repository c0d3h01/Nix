{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.dircolors;
in {
  options.dotfiles.home.shell.dircolors.enable = mkEnableOption "dircolors";

  config = mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
