{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.fonts;
in {
  options.dotfiles.home.fonts.enable = mkEnableOption "User fonts";

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.symbols-only
      cascadia-code

      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
  };
}
