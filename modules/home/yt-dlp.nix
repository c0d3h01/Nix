{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.yt-dlp;
in {
  options.dotfiles.home.features.yt-dlp.enable = mkEnableOption "yt-dlp video downloader";

  config = mkIf cfg.enable {
    programs.yt-dlp = {
      enable = true;
      settings = {
        embed-thumbnail = true;
        embed-subs = true;
        sub-langs = "all";
        downloader = "aria2c";
        downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      };
    };
  };
}
