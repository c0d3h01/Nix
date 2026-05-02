{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce concatStringsSep;

  avoid = concatStringsSep "|" [
    "(h|H)yprland"
    "sway"
    "Xwayland"
    "cryptsetup"
    "dbus-.*"
    "gpg-agent"
    "greetd"
    "ssh-agent"
    ".*qemu-system.*"
    "sddm"
    "sshd"
    "systemd"
    "systemd-.*"
    "wezterm"
    "kitty"
    "ghostty"
    "bash"
    "zsh"
    "fish"
    "n?vim"
    "akkoma"
  ];

  prefer = concatStringsSep "|" [
    "Web Content"
    "Isolated Web Co"
    "firefox.*"
    "chrom(e|ium).*"
    "electron"
    "dotnet"
    ".*.exe"
    "java.*"
    "pipewire(.*)"
    "nix"
    "npm"
    "node"
    "pipewire(.*)"
  ];
in {
  # Kill preferred user workloads before memory pressure freezes the system.
  services = {
    earlyoom = {
      enable = true;
      enableNotifications = true;

      reportInterval = 0;
      freeSwapThreshold = 5;
      freeSwapKillThreshold = 2;
      freeMemThreshold = 5;
      freeMemKillThreshold = 2;

      extraArgs = [
        "-g"
        "--avoid"
        "'^(${avoid})$'"
        "--prefer"
        "'^(${prefer})$'"
      ];

      # Keep a minimal kill record until this is wired into the journal.
      killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
        echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
      '';
    };

    systembus-notify.enable = mkForce true;
  };
}
