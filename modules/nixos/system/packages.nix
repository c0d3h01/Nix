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
  environment.systemPackages = with pkgs;
    mkIf isWorkstation [
      vscode-fhs
      # antigravity-fhs
      # chromium
    ];
}
