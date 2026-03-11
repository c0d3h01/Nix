{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkMerge mkAfter;
  cfg = config.dotfiles.nixos.system.diff;
in {
  options.dotfiles.nixos.system.diff.enable = mkEnableOption "NixOS system diff on switch";

  config = mkMerge [
    (mkIf cfg.enable {
      system.activationScripts.diff = {
        text = ''
          if [[ -e /run/current-system ]]; then
            echo "=== Diff to current-system ==="
            ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
            echo "=== End of system diff ==="
          fi
        '';
      };
    })

    (mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
      system.activationScripts.diff.supportsDryActivation = true;
    })

    (mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      system.activationScripts.postActivation.text = mkAfter ''
        ${config.system.activationScripts.diff.text}
      '';
    })
  ];
}
