{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.gnomeDesktop;
in {
  options.services.gnomeDesktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the complete GNOME desktop environment with customizations.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    services.displayManager = {
      gdm.enable = true;
      defaultSession = "gnome";
    };

    services.gnome = {
      localsearch.enable = lib.mkForce false;
      tinysparql.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-initial-setup.enable = lib.mkForce false;
    };

    # GSConnect is a GNOME Shell extension, not a drop-in package replacement.
    # This is the idiomatic NixOS way to enable it.
    programs.kdeconnect.enable = true;
    environment.gnome.extraExtensions = [pkgs.gnomeExtensions.gsconnect];

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnome-text-editor
      gnome-console
      gnome-photos
      vlc
      kdePackages.partitionmanager
    ];

    environment.gnome.excludePackages = with pkgs; [
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
}
