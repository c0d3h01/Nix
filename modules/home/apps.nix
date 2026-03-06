{
  pkgs,
  userConfig,
  lib,
  ...
}: let
  isWorkstation = userConfig.workstation or false;

  cli = with pkgs; [
    fd
    tree
    gitFull
    git-lfs
    lazygit
    ripgrep
    yt-dlp
    glances
    stow
    bat
    imagemagick
    mise
  ];

  apps = [];
in {
  home.packages =
    cli
    ++ lib.optionals isWorkstation apps;
}
