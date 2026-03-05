{
  lib,
  pkgs,
  ...
}: let
  isNixOS = builtins.pathExists /etc/NIXOS;
  nixglPkgs = pkgs.nixgl or {};
  hasNixGL = nixglPkgs != {};

  wrappers =
    lib.optionals (nixglPkgs ? nixGLIntel) [nixglPkgs.nixGLIntel]
    ++ lib.optionals (nixglPkgs ? nixVulkanIntel) [nixglPkgs.nixVulkanIntel];

  defaultWrapper =
    nixglPkgs.nixGLIntel or null;

  nixGLAutoWrapper =
    lib.optional (defaultWrapper != null)
    (pkgs.writeShellScriptBin "nixGLAuto" ''
      exec ${lib.getExe defaultWrapper} "$@"
    '');
in {
  config = lib.mkIf (!isNixOS && hasNixGL) {
    home.packages =
      wrappers
      ++ nixGLAutoWrapper;
  };
}
