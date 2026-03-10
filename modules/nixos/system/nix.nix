{
  lib,
  inputs,
  pkgs,
  ...
}: {
  nix = {
    channel.enable = lib.mkDefault true;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    daemonCPUSchedPolicy = lib.mkDefault "batch";
    daemonIOSchedClass = lib.mkDefault "idle";

    gc = {
      automatic = true;
      dates = lib.mkDefault "daily";
      randomizedDelaySec = lib.mkDefault "45min";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = lib.mkDefault "Sun 04:00";
      randomizedDelaySec = lib.mkDefault "30min";
    };

    settings = {
      min-free = 1024 * 1024 * 1024; # 1 GiB
      max-free = 5 * 1024 * 1024 * 1024; # 5 GiB

      auto-optimise-store = false;

      max-jobs = 4;
      cores = 2;

      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
      ];

      experimental-features = [
        "flakes"
        "nix-command"
        "auto-allocate-uids"
      ];

      accept-flake-config = false;
      use-registries = true;
      flake-registry = "";

      use-xdg-base-directories = true;
      sandbox = pkgs.stdenv.hostPlatform.isLinux;

      show-trace = true;
      log-lines = 30;
      keep-going = false;
      warn-dirty = false;

      http-connections = 25;
      connect-timeout = 10;
      download-attempts = 3;

      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      require-sigs = true;

      keep-derivations = true;
      keep-outputs = true;

      allowed-users = ["root" "@wheel"];
      trusted-users = ["root" "@wheel"];
    };
  };
}
