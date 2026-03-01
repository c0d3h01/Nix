{self, ...}: {
  perSystem = {pkgs, ...}: let
    mkFormatter = pkgs': let
      inherit (pkgs') lib;
    in
      pkgs'.treefmt.withConfig {
        runtimeInputs = with pkgs'; [
          actionlint
          deadnix
          alejandra
          shellcheck
          shfmt
          statix

          (writeShellScriptBin "statix-fix" ''
            for file in "$@"; do
              ${lib.getExe statix} fix "$file"
            done
          '')
        ];

        settings = {
          on-unmatched = "info";
          tree-root-file = "flake.nix";

          excludes = [
            ".github"
            "secrets/*"
            ".envrc"
            "*.lock"
            "*.patch"
            "*.age"
          ];

          formatter = {
            actionlint = {
              command = "actionlint";
              includes = [
                ".github/workflows/*.yml"
                ".github/workflows/*.yaml"
              ];
            };

            deadnix = {
              command = "deadnix";
              includes = ["*.nix"];
            };

            alejandra = {
              command = "alejandra";
              includes = ["*.nix"];
            };

            shellcheck = {
              command = "shellcheck";
              includes = [
                "*.sh"
                "*.bash"
              ];
            };

            shfmt = {
              command = "shfmt";
              options = [
                "-s"
                "-w"
                "-i"
                "2"
              ];
              includes = [
                "*.sh"
                "*.bashrc"
                "*.bash_profile"
                "*.zshrc"
                "*.envrc"
                "*.envrc.private-template"
              ];
            };

            statix = {
              command = "statix-fix";
              includes = ["*.nix"];
            };
          };
        };
      };

    formatterPkg = mkFormatter pkgs;
  in {
    formatter = formatterPkg;

    checks.formatting =
      pkgs.runCommandLocal "formatting-checks"
      {
        nativeBuildInputs = [formatterPkg];
      }
      ''
        cd ${self}
        treefmt --no-cache --fail-on-change
        touch $out
      '';
  };
}
