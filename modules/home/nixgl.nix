{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.nixgl;
in {
  options.dotfiles.home.nixgl.enable = mkEnableOption "NixGL support for non-NixOS hosts";

  config = mkIf (cfg.enable && !hostConfig.isNixOS) {
    home.packages = lib.optionals (pkgs ? nixgl && pkgs.nixgl ? nixGLIntel) [
      pkgs.nixgl.nixGLIntel
    ];
  };
}
