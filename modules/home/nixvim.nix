{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.editor.nixvim;
in {
  options.dotfiles.home.editor.nixvim.enable = mkEnableOption "NixVim editor configuration";

  imports = [inputs.nixvim.homeModules.nixvim];

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      colorschemes.gruvbox.enable = true;
      plugins.lualine.enable = true;
    };
  };
}
