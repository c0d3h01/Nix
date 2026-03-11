{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.dev.gh;
in {
  options.dotfiles.home.dev.gh.enable = mkEnableOption "GitHub CLI";

  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;

      settings = {
        editor = "nvim";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    programs.gh.extensions = [];
  };
}
