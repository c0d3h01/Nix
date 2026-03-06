{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.alacritty;
in {
  options.dotfiles.home.features.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = pkgs.wrapWithNixGL pkgs.alacritty "alacritty";
    };
  };
}
