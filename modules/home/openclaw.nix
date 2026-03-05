{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.home.features.openclaw;
in {
  options.dotfiles.home.features.openclaw.enable = mkEnableOption "OpenClaw";

  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  config = mkIf cfg.enable {
    programs.openclaw = {
      enable = true;

      config = {
        gateway = {
          mode = "local";
        };

        agents = {
          defaults = {
            model = {
              primary = "google/gemini-3-pro-preview";
            };
          };
        };

        channels.telegram = {
          tokenFile = config.sops.secrets.openclaw-telegram-token.path;
          allowFrom = [123456];
          groups = {
            "*" = {requireMention = true;};
          };
        };
      };

      instances.default = {
        enable = true;
        plugins = [
        ];
      };
    };

    sops.secrets = {
      openclaw-telegram-token = {};
      openclaw-env = {};
    };

    systemd.user.services.openclaw-gateway = {
      Service.EnvironmentFile = [config.sops.secrets.openclaw-env.path];
    };
  };
}
