{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.dev.delta;
in {
  options.dotfiles.home.dev.delta.enable = mkEnableOption "delta diff viewer";

  config = mkIf cfg.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
