{
  lib,
  pkgs,
  hostProfile,
  hardwareProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  # Nix Configuration - Optimized for low-RAM systems with automatic GC
  nix = {
    package = pkgs.lix;

    # Prioritize UI responsiveness during builds by deprioritizing build processes
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";

    # Automatic garbage collection to free disk space
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    # Store optimization to save disk space
    optimise = {
      automatic = true;
      dates = "Sun 04:00";
    };

    settings = {
      # Prevent disk full errors on small NVMe/SSD
      min-free = 1024 * 1024 * 1024; # 1GB minimum free
      max-free = 5 * 1024 * 1024 * 1024; # 5GB target free

      # CRITICAL for 6GB RAM: Limit parallel builds to prevent OOM kills
      max-jobs = hardwareProfile.maxBuildJobs;
      cores = hardwareProfile.buildCores;
      auto-allocate-uids = true;

      # Enable modern Nix features
      experimental-features = ["nix-command" "flakes" "auto-allocate-uids"];

      # Network & Binary Caches
      http-connections = 25;
      builders-use-substitutes = true;

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = ["root" "@wheel"];
    };
  };

  # Additional Nix-related optimizations
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
    allowUnsupportedSystem = false;
  };
}
