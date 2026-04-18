{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  gtk = lib.mkMerge [
    (mkIf config.services.kdeDesktop.enable {
      enable = true;

      theme = {
        package = pkgs.kdePackages.breeze-gtk;
        name = "Breeze-Dark";
      };

      cursorTheme = {
        package = pkgs.kdePackages.breeze;
        name = "Breeze-Dark";
      };

      iconTheme = {
        package = pkgs.kdePackages.breeze-icons;
        name = "Breeze-Dark";
      };

      gtk2 = {
        extraConfig = ''
          gtk-alternative-button-order = 1
        '';
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-decoration-layout = "icon:minimize,maximize,close";
      };

      gtk4 = {
        inherit (config.gtk) theme;
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
      };
    })

    (mkIf config.services.gnomeDesktop.enable {
      enable = true;

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };

      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };

      gtk4 = {
        inherit (config.gtk) theme;
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };
    })
  ];
}
