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
    inputs.spicetify-nix.homeManagerModules.default
  ];

  config.programs.spicetify = mkIf (hostConfig.workstation or false) (
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;

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
