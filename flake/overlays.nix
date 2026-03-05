{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  isNixOS = builtins.pathExists /etc/NIXOS;
  overlays =
    [
      (final: prev: {
        xorg =
          prev.xorg
          // {
            inherit (prev) lndir;
          };

        # ── nixGL wrapper ─────────────────────────────────────────────────
        # Usage: pkgs.wrapWithNixGL pkgs.kitty "kitty"
        # No-op on NixOS; auto-detects GL driver on other distros.
        wrapWithNixGL = pkg: binName: let
          bin =
            if binName != null
            then binName
            else pkg.pname or (lib.getName pkg);
        in
          if isNixOS || !(final ? nixgl)
          then pkg
          else let
            nixGLBin = lib.getExe final.nixgl.nixGLIntel;
          in
            final.symlinkJoin {
              name = "${pkg.name or bin}-nixgl";
              paths = [pkg];
              buildInputs = [final.makeWrapper];
              postBuild = ''
                if [ -f "$out/bin/${bin}" ]; then
                  rm "$out/bin/${bin}"
                  makeWrapper ${nixGLBin} "$out/bin/${bin}" \
                    --add-flags "${pkg}/bin/${bin}"
                fi
              '';
            };
      })
      inputs.nix-openclaw.overlays.default
      inputs.nur.overlays.default
    ]
    ++ lib.optionals (!isNixOS) [
      inputs.nixgl.overlays.default
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
