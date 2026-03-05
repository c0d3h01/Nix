{
  config,
  lib,
  pkgs,
  inputs,
  userConfig,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.spicetify;
in {
  options.dotfiles.home.features.spicetify.enable = mkEnableOption "Spicetify";

  imports = [
    inputs.spicetify.homeManagerModules.default
  ];

  config.programs.spicetify = mkIf ((userConfig.workstation or false) && cfg.enable) (
    let
      spicePkgs = inputs.spicetify.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      theme = spicePkgs.themes.sleek;
      colorScheme = "Nord";

      enabledCustomApps = with spicePkgs.apps; [
        ncsVisualizer
        newReleases
      ];

      enabledExtensions = with spicePkgs.extensions; [
        beautifulLyrics
        goToSong
        history
        adblock
      ];
    }
  );
}
