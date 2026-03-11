# pkgs.wrapWithNixGL: wraps GPU apps through nixGLIntel on non-NixOS, no-op on NixOS
{isNixOS}: final: prev: {
  wrapWithNixGL = pkg: binName:
    if isNixOS
    then pkg
    else
      prev.runCommand "${pkg.pname or binName}-nixgl" {
        nativeBuildInputs = [prev.makeWrapper];
        meta = pkg.meta or {};
      } ''
        mkdir -p $out/bin

        for item in ${pkg}/*; do
          [ "$(basename "$item")" = "bin" ] && continue
          ln -s "$item" "$out/$(basename "$item")"
        done

        for bin in ${pkg}/bin/*; do
          ln -s "$bin" "$out/bin/$(basename "$bin")"
        done

        rm -f "$out/bin/${binName}"
        makeWrapper ${final.nixgl.nixGLIntel}/bin/nixGLIntel \
          "$out/bin/${binName}" \
          --add-flags "${pkg}/bin/${binName}"
      '';
}
