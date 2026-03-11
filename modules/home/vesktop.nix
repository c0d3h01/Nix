{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.vesktop;
in {
  options.dotfiles.home.features.vesktop.enable = mkEnableOption "Vesktop Discord client";

  config = mkIf cfg.enable {
    programs.vesktop = {
      enable = true;

      settings = {
        appBadge = false;
        arRPC = true;
        checkUpdates = false;
        customTitleBar = false;
        disableMinSize = true;
        minimizeToTray = false;
        tray = false;
        staticTitle = true;
        discordBranch = "stable";

        hardwareAcceleration = true;
        openLinksWithElectron = false;

        splashTheming = true;
        splashBackground = "#000000";
        splashColor = "#ffffff";
        splashAnimationDuration = 500;

        saveWindowState = true;
        disableAudioControl = false;
      };

      vencord.settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        useQuickCss = true;
        enableReactDevtools = false;
        frameless = false;
        transparent = false;
        winCtrlQ = false;
        disableMinSize = true;
        winNativeTitleBar = false;
      };
    };
  };
}
