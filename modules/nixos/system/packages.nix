{
  hostProfile,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (hostProfile) isWorkstation;

in {
  environment.systemPackages = mkIf isWorkstation [
    pkgs.vscode-fhs
    pkgs.antigravity-fhs
  ];
}
