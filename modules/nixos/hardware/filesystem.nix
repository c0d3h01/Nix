{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkMerge mkDefault;
  cfg = config.dotfiles.nixos.hardware.filesystem;
  rootFs = config.fileSystems."/".fsType;
  isXfs = rootFs == "xfs";
  isBtrfs = rootFs == "btrfs";
in {
  options.dotfiles.nixos.hardware.filesystem.enable = mkEnableOption "Filesystem scrubs and tools";

  config = mkIf cfg.enable {
    environment.systemPackages = mkMerge [
      (mkIf isXfs [pkgs.xfsprogs])
      (mkIf isBtrfs [pkgs.btrfs-progs])
    ];

    services.fstrim.enable = mkDefault true;

    systemd.services.xfs-scrub = mkIf isXfs {
      description = "XFS filesystem scrub for data integrity";
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        ExecStart = "${pkgs.xfsprogs}/bin/xfs_scrub -v /";
      };
    };

    systemd.timers.xfs-scrub = mkIf isXfs {
      enable = true;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };

    systemd.services.btrfs-scrub = mkIf isBtrfs {
      description = "Btrfs filesystem scrub for data integrity";
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        ExecStart = "${pkgs.btrfs-progs}/bin/btrfs scrub start -B /";
      };
    };

    systemd.timers.btrfs-scrub = mkIf isBtrfs {
      enable = true;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
  };
}
