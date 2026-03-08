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

      theme = "solarized_osaka";
      themePackage = pkgs.alacritty-theme;

      settings = {
        shell = "zellij";
        selection.save_to_clipboard = false;
        mouse.hide_when_typing = true;

        font.normal.family = "JetBrainsMono Nerd Font";
        font.bold.family = "JetBrainsMono Nerd Font";
        font.italic.family = "JetBrainsMono Nerd Font";
        font.size = 13.0;

        keyboard.bindings = [
          {
            key = "K";
            mods = "Control";
            chars = "\\u000c";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "Enter";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
          {
            key = "Equals";
            mods = "Control|Shift";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Control|Shift";
            action = "DecreaseFontSize";
          }
          {
            key = "Key0";
            mods = "Control|Shift";
            action = "ResetFontSize";
          }
        ];
      };
    };
  };
}
