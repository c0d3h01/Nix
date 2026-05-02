{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
in {
  options.services.kdeDesktop = {
    enable = mkOption {
      type = lib.types.bool;
      default = false;
      description = "Plasma 6 Desktop Environment";
    };
  };

  config = mkIf config.services.kdeDesktop.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager = {
      defaultSession = "plasmax11";
      sddm.enable = true;
      sddm.wayland.enable = true;
    };

    programs.kdeconnect.enable = true;
    networking.firewall = mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    environment.systemPackages = with pkgs; [
      # KDE Utilities
      kdePackages.discover # Software center for Flatpaks/firmware updates
      kdePackages.kcalc # Calculator
      kdePackages.kcharselect # Character map
      kdePackages.kclock # Clock app
      kdePackages.kcolorchooser # Color picker
      kdePackages.kolourpaint # Simple paint program
      kdePackages.ksystemlog # System log viewer
      kdePackages.sddm-kcm # SDDM configuration module
      kdiff3 # File / directory comparison tool
      kdePackages.kate # Text editor

      # Hardware/System Utilities
      kdePackages.isoimagewriter # Write hybrid ISOs to USB
      kdePackages.partitionmanager # Disk and partition management
      hardinfo2 # System benchmarks and hardware info
      wayland-utils # Wayland diagnostic tools
      wl-clipboard # Wayland copy/paste support
      vlc # Media player
      kdePackages.konsole # Terminal
      kdePackages.plasma-browser-integration
      kdePackages.sonnet # Spelling framework for Qt.
    ];
  };
}
