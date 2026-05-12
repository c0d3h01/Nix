{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  options.services.gnomeDesktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GNOME desktop with optimizations.";
    };
  };

  config = mkIf config.services.gnomeDesktop.enable {
    services.desktopManager.gnome.enable = true;
    services.displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
      defaultSession = "gnome";
    };

    services.gnome = {
      # Disable file indexing
      localsearch.enable = mkForce false;
      tinysparql.enable = mkForce false;
      # Disable online accounts
      gnome-online-accounts.enable = mkForce false;
      # Disable initial setup wizard
      gnome-initial-setup.enable = mkForce false;
      # Disable browser connector
      gnome-browser-connector.enable = mkForce false;
      # Disable GNOME Software
      gnome-software.enable = mkForce false;
      # Disable remote desktop
      gnome-remote-desktop.enable = mkForce false;
    };

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    networking.firewall = mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnome-text-editor
      gnome-console # Gnome fallback terminal
      ptyxis # Terminal for GNOME with first-class support for containers
    ];

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
      decibels # Music player
      gnome-music
      gnome-photos
      geary # Email client
      gnome-font-viewer
      gnome-usage
      gnome-system-monitor
      baobab # Disk usage analyzer
      epiphany # Web browser
      yelp # Help viewer
      gnome-contacts
      gnome-weather
      gnome-maps
      gnome-connections
      gnome-remote-desktop
      gnome-software
    ];
  };
}
