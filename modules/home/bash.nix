{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.bash;
in {
  options.dotfiles.home.shell.bash.enable = mkEnableOption "Bash shell";

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
    };
  };
}
