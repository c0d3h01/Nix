{
  config,
  hostProfile,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optionals;
  inherit (hostProfile) isWorkstation;
  cfg = config.dotfiles.nixos.system.packages;

  desktopApps = with pkgs; [
    vscode-fhs
    brave
    antigravity-fhs
    postman
    github-desktop
  ];
in {
  options.dotfiles.nixos.system.packages.enable = mkEnableOption "Default system packages";

  config = mkIf cfg.enable {
    environment.systemPackages = optionals isWorkstation desktopApps;
  };
}
