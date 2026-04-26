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
      description = "Enable GNOME desktop with power and memory optimizations.";
    };
  };

  config = lib.mkIf cfg.enable {
    # =======================================================================
    # CORE GNOME
    # =======================================================================
    services.desktopManager.gnome.enable = true;

    services.displayManager = {
      gdm = {
        enable = true;
        wayland = true; # Wayland is more power efficient than X11
      };
      defaultSession = "gnome";
    };

    # =======================================================================
    # DISABLE HEAVY GNOME SERVICES (reduce RAM and CPU usage)
    # =======================================================================
    services.gnome = {
      # Disable file indexing (high RAM/CPU usage)
      localsearch.enable = lib.mkForce false;
      tinysparql.enable = lib.mkForce false;

      # Disable online accounts (not needed for most users)
      gnome-online-accounts.enable = lib.mkForce false;

      # Disable initial setup wizard
      gnome-initial-setup.enable = lib.mkForce false;

      # Disable browser connector (security + RAM)
      gnome-browser-connector.enable = lib.mkForce false;

      # Disable GNOME Software (auto-updates can be handled by nix)
      gnome-software.enable = lib.mkForce false;

      # Disable remote desktop (security)
      gnome-remote-desktop.enable = lib.mkForce false;
    };

    # =======================================================================
    # GNOME SHELL MEMORY OPTIMIZATIONS
    # =======================================================================
    systemd.user.services.gnome-shell = {
      serviceConfig = {
        Environment = "G_ENABLE_DIAGNOSTIC=0";
        Nice = -5; # Higher priority for responsiveness
        IOSchedulingClass = "idle"; # Lower I/O priority
        MemoryHigh = "512M"; # Soft limit
        MemoryMax = "768M"; # Hard limit
      };
    };

    # Limit mutter memory usage
    systemd.user.services.mutter = {
      serviceConfig = {
        MemoryHigh = "384M";
        MemoryMax = "512M";
      };
    };

    # =======================================================================
    # KDE CONNECT (via GSConnect extension)
    # =======================================================================
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    # =======================================================================
    # ESSENTIAL PACKAGES
    # =======================================================================
    environment.systemPackages = with pkgs; [
      gnome-tweaks # Essential for GNOME customization
      gnome-text-editor # Lightweight text editor
      gnome-console # Modern terminal (kgx)
    ];

    # =======================================================================
    # EXCLUDE GNOME BLOAT (reduce RAM footprint)
    # =======================================================================
    environment.gnome.excludePackages = with pkgs; [
      # Documentation/tutorials (not needed for experienced users)
      gnome-tour
      gnome-user-docs

      # Media apps (use alternatives)
      decibels # Music player
      gnome-music
      gnome-photos
      geary # Email client

      # Utilities (redundant or heavy)
      gnome-font-viewer
      gnome-usage # Use htop/neofetch instead
      gnome-system-monitor # Redundant with htop
      baobab # Disk usage analyzer

      # Apps most users don't need
      epiphany # Web browser (use Brave/Firefox)
      yelp # Help viewer
      gnome-contacts
      gnome-weather
      gnome-maps
      gnome-connections
      gnome-remote-desktop
      gnome-software # Disabled above, exclude from environment
    ];
  };
}
