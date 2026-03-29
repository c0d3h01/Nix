{
  hostProfile,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  # Essential system packages for development workstation
  programs.firefox.enable = hostProfile.isWorkstation;

  environment.systemPackages = mkIf hostProfile.isWorkstation (with pkgs; [
    # Development Tools
    git
    gh # GitHub CLI
    lazygit # Terminal Git UI

    # Code Editors
    vscode-fhs
    jetbrains.rust-toolbox # Rust IDE

    # Browsers
    google-chrome

    # Utilities
    antigravity-fhs
    file-roller
    gnome-disk-utility
  ]);
}
