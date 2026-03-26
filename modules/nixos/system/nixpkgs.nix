{lib, ...}: let
  inherit (lib) mkDefault;
in {
  nixpkgs = {
    hostPlatform = mkDefault "x86_64-linux";

    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
  };
}
