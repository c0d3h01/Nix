{
  config,
  pkgs,
  lib,
  hostConfig,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = {
    gtk = lib.mkMerge [
      (mkIf (hostConfig.windowManager == "plasma") {
        enable = true;

        theme = {
          package = pkgs.kdePackages.breeze-gtk;
          name = "Breeze-Dark";
        };

        cursorTheme = {
          package = pkgs.kdePackages.breeze;
          name = "Breeze_Light";
        };

        iconTheme = {
          package = pkgs.kdePackages.breeze-icons;
          name = "breeze-dark";
        };

        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          extraConfig = ''
            gtk-alternative-button-order = 1
          '';
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
      })

      (mkIf (hostConfig.windowManager == "gnome") {
        enable = true;

        theme = {
          name = "Orchis-Dark";
          package = pkgs.orchis-theme;
        };

        cursorTheme = {
          name = "Bibata-Modern-Ice";
          size = 24;
          package = pkgs.bibata-cursors;
        };

        iconTheme = {
          name = "Tela-circle";
          package = pkgs.tela-circle-icon-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      })
    ];
  };
}
