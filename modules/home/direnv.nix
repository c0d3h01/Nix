{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.direnv;
in {
  options.dotfiles.home.shell.direnv.enable = mkEnableOption "direnv";

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      silent = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
