{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  config = mkIf (userConfig.windowManager == "gnome") {
    # GNOME desktop environment configuration
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.defaultSession = "gnome";

    # KDE Connect requires specific ports to be open
    networking.firewall = lib.mkIf config.programs.firewall.enable {
      allowedTCPPorts = [1716]; # KDE connect port
      allowedUDPPorts = [1716];
    };

    # Enable tuned service for performance tuning
    services.tuned.enable = true;
    services.tuned.settings.dynamic_tuning = true;

    # Disable - useless services; trackers
    services.gnome.localsearch.enable = mkForce false;
    services.gnome.tinysparql.enable = mkForce false;
    services.gnome.gnome-online-accounts.enable = mkForce false;
    services.gnome.gnome-initial-setup.enable = mkForce false;

    # Exclude unwanted GNOME packages
    environment = {
      systemPackages = with pkgs; [
        gnome-tweaks
        gnome-text-editor
        gnome-console
        gnome-photos
        vlc
        libreoffice-still
        playerctl # gsconnect play/pause command
        pamixer # gcsconnect volume control

        # Gnome extensions
        gnomeExtensions.gsconnect
        gnomeExtensions.dash-to-dock
      ];

      gnome.excludePackages = with pkgs; [
        gnome-tour
        decibels
        gnome-font-viewer
        epiphany
        yelp
        baobab
        gnome-music
        gnome-remote-desktop
        gnome-usage
        gnome-contacts
        gnome-weather
        gnome-maps
        gnome-connections
        gnome-system-monitor
        gnome-user-docs
        geary
      ];
    };
  };
}
