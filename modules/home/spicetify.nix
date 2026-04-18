{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify = let
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
  };
}
