{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.ghostty;
in {
  options.dotfiles.home.features.ghostty = {
    enable = mkEnableOption "Ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = pkgs.wrapWithNixGL pkgs.ghostty "ghostty";
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        # Theme
        theme = "catppuccin-mocha";

        # Font config
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;

        # Background transparency
        background-opacity = 0.85;
        background-blur-radius = 20;

        # Window
        clipboard-read = "allow";
        clipboard-write = "allow";
        confirm-close-surface = false;
        gtk-titlebar = true;
        resize-overlay = "never";
        shell-integration = "zsh";
        window-padding-x = 14;
        window-padding-y = 14;

        # macOS settings
        macos-non-native-fullscreen = false;
        macos-option-as-alt = true;
        mouse-hide-while-typing = true;

        # Keybindings
        keybind = [
          "super+c=copy_to_clipboard"
          "super+d=new_split:right"
          "super+k=clear_screen"
          "super+left_bracket=goto_split:previous"
          "super+n=new_window"
          "super+q=quit"
          "super+right_bracket=goto_split:next"
          "super+shift+c=copy_to_clipboard"
          "super+shift+comma=reload_config"
          "super+shift+d=new_split:down"
          "super+shift+left_bracket=previous_tab"
          "super+shift+right_bracket=next_tab"
          "super+shift+v=paste_from_clipboard"
          "super+shift+w=close_window"
          "super+t=new_tab"
          "super+v=paste_from_clipboard"
          "super+w=close_surface"
          "super+zero=reset_font_size"
        ];
      };

      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          cursor-text = "11111b";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#a6adc8"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#bac2de"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
          split-divider-color = "313244";
        };
      };
    };
  };
}
