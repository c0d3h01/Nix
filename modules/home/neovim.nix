{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.dev.neovim;
in {
  options.dotfiles.home.dev.neovim.enable = mkEnableOption "Neovim editor";

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      withNodeJs = true;
      withPython3 = true;

      extraPackages = with pkgs; [
        tree-sitter
      ];
    };
  };
}
