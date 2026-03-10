{
  config,
  pkgs,
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  config = mkIf (hostProfile.windowManager == "gnome") {
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.defaultSession = "gnome";

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716]; # KDE connect port
      allowedUDPPorts = [1716];
    };

    services.gnome.localsearch.enable = mkForce false;
    services.gnome.tinysparql.enable = mkForce false;
    services.gnome.gnome-online-accounts.enable = mkForce false;
    services.gnome.gnome-initial-setup.enable = mkForce false;

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

        gnomeExtensions.gsconnect
        # gnomeExtensions.dash-to-dock
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
