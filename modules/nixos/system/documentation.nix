{lib, ...}: let
  inherit (lib) mkForce;

in {
  # Disable documentation pages to save disk space and reduce clutter.
  documentation = {
    enable = mkForce false;
    dev.enable = mkForce false;
    doc.enable = mkForce false;
    info.enable = mkForce false;
    nixos.enable = mkForce false;

    man = {
      enable = mkForce false;
      cache.enable = mkForce false;
      man-db.enable = mkForce false;
      mandoc.enable = mkForce false;
    };
  };
}
