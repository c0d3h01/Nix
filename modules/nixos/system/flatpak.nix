{
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  services.flatpak.enable = mkIf hostProfile.isWorkstation true;
}
