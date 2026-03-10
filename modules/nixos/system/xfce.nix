{
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (hostProfile.windowManager == "xfce") {
    services.xserver.desktopManager.xfce.enable = true;
    services.displayManager.defaultSession = "xfce";
  };
}
