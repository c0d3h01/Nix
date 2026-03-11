{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.shell.fd;
in {
  options.dotfiles.home.shell.fd.enable = mkEnableOption "fd file finder";

  config = mkIf cfg.enable {
    programs.fd = {
      enable = true;

      hidden = true;
      ignores = [
        ".git/"
        "*.bak"
      ];
    };
  };
}
