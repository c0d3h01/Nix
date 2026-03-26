{pkgs, ...}: {
  programs.ghostty = {
    enable = false;
    package = pkgs.ghostty;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "Solarized Dark Patched";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13.0;

      clipboard-read = "allow";
      clipboard-write = "allow";
      confirm-close-surface = false;
      gtk-titlebar = true;
      background-opacity = 0.85;
      background-blur-radius = 20;

      macos-non-native-fullscreen = false;
      macos-option-as-alt = true;
      mouse-hide-while-typing = true;

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
  };
}
