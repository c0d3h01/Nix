{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce concatStringsSep;

  avoid = concatStringsSep "|" [
    "gnome-shell"
    "mutter"
    "gdm"
    "evolution-data-server"
    "gsd-.*" # GNOME Settings Daemons
    "Xwayland"
    "dbus-.*"
    "systemd"
    "systemd-.*"
    "cryptsetup"
    "gpg-agent"
    "ssh-agent"
    "sshd"
    "ghostty"
    "kitty"
    "ptyxis"
  ];

  prefer = concatStringsSep "|" [
    "firefox.*"
    "chrom(e|ium).*"
    "brave-browser"
    "electron"
    "java.*"
    "python.*"
    "go"
    "rustc"
    "pipewire(.*)"
    "gnome-software"
    "evolution"
    "nix"
    "npm"
    "node"
    "pipewire(.*)"
    "discord"
    "slack"
    "spotify"
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
