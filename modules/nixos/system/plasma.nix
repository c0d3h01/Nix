{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.kdeDesktop;
in {
  options.services.kdeDesktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the complete KDE Plasma 6 environment with default apps & KDE Connect.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      defaultSession = "plasmax11";

      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    programs.kdeconnect.enable = true;

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [1716];
      allowedUDPPorts = [1716];
    };

    environment.systemPackages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.konsole
      kdePackages.plasma-browser-integration
      kdePackages.partitionmanager
      kdePackages.kpat
      kdePackages.sonnet
      gnome-logs
      libreoffice-still
      vlc
    ];
  };
}
