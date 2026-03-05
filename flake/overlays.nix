{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  isNixOS = builtins.pathExists /etc/NIXOS;
  overlays = [
    (final: prev: {
      xorg =
        prev.xorg
        // {
          inherit (prev) lndir;
        };

      # ── nixGL wrapper helper ──────────────────────────────────────────
      # Usage: pkgs.wrapWithNixGL pkgs.wezterm "wezterm-gui"
      #   pkg      – the package to wrap
      #   binName  – the GL binary inside the package (defaults to pkg.pname)
      # On NixOS this is a no-op; on other distros it prefixes the binary
      # with nixGLIntel so it picks up the host GL/Vulkan stack.
      wrapWithNixGL = pkg: binName: let
        bin =
          if binName != null
          then binName
          else pkg.pname or (lib.getName pkg);
        nixglPkgs = final.nixgl or {};
      in
        if isNixOS || !(nixglPkgs ? nixGLIntel)
        then pkg
        else
          final.symlinkJoin {
            name = "${pkg.name or bin}-nixgl";
            paths = [pkg];
            buildInputs = [final.makeWrapper];
            postBuild = ''
              if [ -f $out/bin/${bin} ]; then
                wrapProgram $out/bin/${bin} \
                  --prefix PATH : "${lib.makeBinPath [nixglPkgs.nixGLIntel]}"
              fi
            '';
          };
    })
    inputs.nix-openclaw.overlays.default
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
