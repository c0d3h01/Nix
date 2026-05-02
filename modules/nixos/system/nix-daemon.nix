{
  lib,
  pkgs,
  ...
}: {
  nix = {
    # nix alternative - modern nix version.
    # package = pkgs.lixPackageSets.stable.lix;

    # automatic garbage cleaner, scheduled.
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 30d";

    # auto optimization, scheduled.
    optimise.automatic = true;
    optimise.dates = "Sun 04:00";

    # global nix settings.
    settings = {
      # Prevent disk full errors on small NVMe
      min-free = 1024 * 1024 * 1024;
      max-free = 5 * 1024 * 1024 * 1024;

      # nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      max-jobs = 4;
      cores = 4;
      auto-optimise-store = true;
      fallback = true;
      warn-dirty = false;
      experimental-features = ["nix-command" "flakes"];

      # Network & Caches
      http-connections = 128;
      max-substitution-jobs = 128;
      builders-use-substitutes = true;

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  systemd.timers.nix-cleanup-gcroots = {
    timerConfig = {
      OnCalendar = ["weekly"];
      Persistent = true;
    };
    wantedBy = ["timers.target"];
  };
  systemd.services.nix-cleanup-gcroots = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        # delete automatic gcroots older than 30 days
        "${pkgs.findutils}/bin/find /nix/var/nix/gcroots/auto /nix/var/nix/gcroots/per-user -type l -mtime +30 -delete"
        # created by nix-collect-garbage, might be stale
        "${pkgs.findutils}/bin/find /nix/var/nix/temproots -type f -mtime +10 -delete"
        # delete broken symlinks
        "${pkgs.findutils}/bin/find /nix/var/nix/gcroots -xtype l -delete"
      ];
    };
  };

  programs.command-not-found.enable = false;
}
