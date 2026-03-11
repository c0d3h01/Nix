{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.eza;
in {
  options.dotfiles.home.shell.eza.enable = mkEnableOption "eza ls replacement";

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--color=always"
      ];
    };
  };
}
