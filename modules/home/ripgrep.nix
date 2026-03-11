{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.ripgrep;
in {
  options.dotfiles.home.shell.ripgrep.enable = mkEnableOption "ripgrep search tool";

  config = mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;

      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
        "--pretty"
      ];
    };
  };
}
