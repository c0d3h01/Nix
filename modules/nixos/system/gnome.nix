{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
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
      localsearch.enable = lib.mkForce false;
      tinysparql.enable = lib.mkForce false;
      # Disable online accounts
      gnome-online-accounts.enable = lib.mkForce false;
      # Disable initial setup wizard
      gnome-initial-setup.enable = lib.mkForce false;
      # Disable browser connector
      gnome-browser-connector.enable = lib.mkForce false;
      # Disable GNOME Software
      gnome-software.enable = lib.mkForce false;
      # Disable remote desktop
      gnome-remote-desktop.enable = lib.mkForce false;
    };

    systemd.user.services.gnome-shell = {
      serviceConfig = {
        Environment = "G_ENABLE_DIAGNOSTIC=0";
        Nice = -5;
        IOSchedulingClass = "idle";
        MemoryHigh = "512M";
        MemoryMax = "768M";
      };
    };

    # Limit mutter memory usage
    systemd.user.services.mutter = {
      serviceConfig = {
        MemoryHigh = "384M";
        MemoryMax = "512M";
      };
    };

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnome-text-editor
      gnome-console
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
