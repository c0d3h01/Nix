{
  lib,
  pkgs,
  inputs,
  userConfig,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    # keep-sorted start
    inputs.spicetify.homeManagerModules.default
    # keep-sorted end
  ];

  programs.spicetify = mkIf userConfig.workstation (
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
