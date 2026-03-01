{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  overlays = [
    inputs.nix-openclaw.overlays.default
    # (final: prev: {
    # })
  ];
in {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
    };
  };

  flake.overlays.default = final: prev:
    lib.foldl' (acc: overlay: lib.recursiveUpdate acc (overlay final prev)) {} overlays;
}
