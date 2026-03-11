{
  lib,
  pkgs,
  hostConfig,
  ...
}: let
  inherit (lib) optionals;
  isWorkstation = hostConfig.workstation or false;
in {
  home.packages = with pkgs;
    [
      tree
      glances
      stow
      imagemagick
      mise
      tldr
      alejandra
      nil
      nixd
      uv
      rustup
      python3
    ]
    ++ optionals isWorkstation [
      freecad
    ];
}
