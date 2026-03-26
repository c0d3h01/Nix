{
  programs.vesktop = {
    enable = false;

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

      splashTheming = false;
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
      transparent = true;
      winCtrlQ = false;
      disableMinSize = true;
      winNativeTitleBar = false;
    };
  };
}
