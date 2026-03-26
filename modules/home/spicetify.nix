{
  config,
  lib,
  pkgs,
  inputs,
  hostConfig,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    inputs.spicetify.homeManagerModules.default
  ];

  config.programs.spicetify = mkIf (hostConfig.workstation or false) (
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
