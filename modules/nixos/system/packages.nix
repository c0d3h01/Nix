{
  hostProfile,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (hostProfile) isWorkstation;
in {
  programs.firefox.enable = isWorkstation;
  environment.systemPackages = mkIf isWorkstation [
    pkgs.vscode-fhs
    pkgs.antigravity-fhs
    pkgs.ytmdesktop
    pkgs.google-chrome
  ];
}
