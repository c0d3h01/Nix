{
  pkgs,
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (hostProfile.windowManager == "kde") {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    services.displayManager.defaultSession = "plasmax11";

    hardware = {
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      kate
      kcalc
      konsole
      plasma-browser-integration
      partitionmanager
    ];
  };
}
