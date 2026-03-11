{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.lsd;
in {
  options.dotfiles.home.shell.lsd.enable = mkEnableOption "lsd ls replacement";

  config = mkIf cfg.enable {
    programs.lsd = {
      enable = true;

      settings = {
        color = {
          when = "always";
          theme = "default";
        };
        size = "short";
        "total-size" = false;
        indicators = false;
        "no-symlink" = false;
        layout = "grid";
        hyperlink = "auto";
        icons = {
          when = "never";
          theme = "fancy";
          separator = "  ";
        };
        date = "relative";
        permission = "rwx";
        sorting = {
          column = "name";
          reverse = false;
          "dir-grouping" = "first";
        };
        blocks = [
          "permission"
          "size"
          "date"
          "git"
          "name"
        ];
        "symlink-arrow" = "->";
      };
    };
  };
}
