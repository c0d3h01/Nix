{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.openclaw = {
    enable = true;

    # Managed documents for the gateway to ingest.
    documents = ./openclaw/documents;

    # Schema-typed OpenClaw config (from upstream).
    config = {
      gateway = {
        mode = "local";
      };

      agents = {
        defaults = {
          model = {
            # Gemini via API key (GEMINI_API_KEY).
            primary = "google/gemini-3-pro-preview";
          };
        };
      };

      channels.telegram = {
        # Bot token managed via sops.
        tokenFile = config.sops.secrets.openclaw-telegram-token.path;
        # TODO: replace with your Telegram user ID (from @userinfobot).
        allowFrom = [123456];
        groups = {
          "*" = {requireMention = true;};
        };
      };
    };

    instances.default = {
      enable = true;
      plugins = [
        # { source = "github:acme/hello-world"; }
      ];
    };
  };

  # OpenClaw secrets are managed via sops-nix.
  sops.secrets = {
    openclaw-telegram-token = {};
    openclaw-env = {};
  };

  # Load API keys at runtime without storing them in the Nix store.
  systemd.user.services.openclaw-gateway = {
    Service.EnvironmentFile = [config.sops.secrets.openclaw-env.path];
  };
}
