{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.chromium;
in {
  options.dotfiles.home.features.chromium.enable = mkEnableOption "Chromium browser";

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      commandLineArgs = [
        "--enable-logging=stderr"
        "--ignore-gpu-blocklist"
        "--oauth2-client-id=77185425430.apps.googleusercontent.com"
        "--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT"
      ];

      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
      ];
    };
  };
}
