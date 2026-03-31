{pkgs}: let
  inherit (pkgs) writeShellApplication;
  inherit (pkgs.lib) optionalAttrs mkIf;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  # Shared partition mounting logic for rescue/troubleshoot
  mountRootScript = fsType: ''
    MNT="''${1:-/mnt}"
    PART_ROOT="/dev/disk/by-label/nixos-root"
    PART_BOOT="/dev/disk/by-label/nixos-boot"

    if [[ $fsType == "btrfs" ]]; then
      mount -t btrfs -o subvol=/@,noatime,compress=zstd:3 "$PART_ROOT" "$MNT"
      mkdir -p "$MNT"/{home,nix,var/tmp,var/log,boot}
      mount -t btrfs -o subvol=/@home,noatime,compress=zstd:3 "$PART_ROOT" "$MNT/home"
      mount -t btrfs -o subvol=/@nix,noatime,compress=zstd:3  "$PART_ROOT" "$MNT/nix"
      mount -t btrfs -o subvol=/@tmp,noatime,compress=zstd:3  "$PART_ROOT" "$MNT/var/tmp"
      mount -t btrfs -o subvol=/@log,noatime,compress=zstd:3  "$PART_ROOT" "$MNT/var/log"
    else
      mount -t ext4 -o noatime,errors=remount-ro "$PART_ROOT" "$MNT"
      mkdir -p "$MNT/boot"
    fi
    mount -o umask=0077 "$PART_BOOT" "$MNT/boot"
  '';

  mkLinuxApp = name: {
    runtimeInputs ? [],
    text,
  }:
    writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [coreutils] ++ runtimeInputs;
      text = "set -euo pipefail\n" + text;
    };
in
  {
    install-nix = writeShellApplication {
      name = "install-nix";
      runtimeInputs = [pkgs.curl];
      text = ''
        echo "Installing Nix (multi-user)..."
        exec curl -L https://nixos.org/nix/install | sh -s -- --daemon
      '';
    };
  }
  // optionalAttrs isLinux {
    partition = mkLinuxApp "partition" {
      runtimeInputs = with pkgs; [
        util-linux
        dosfstools
        btrfs-progs
        e2fsprogs
        gptfdisk
      ];
      text = ''
        DISK="''${1:-}"
        MNT="''${2:-/mnt}"
        BOOT_SIZE="''${BOOT_SIZE:-1G}"

        [[ -n $DISK ]] || { echo "Usage: partition <disk> [mountpoint]"; exit 1; }
        [[ $EUID -eq 0 ]] || { echo "Error: run as root"; exit 1; }
        [[ -b $DISK ]] || { echo "Error: $DISK is not a block device"; exit 1; }

        echo "Root filesystem: [1] btrfs (default)  [2] ext4"
        read -rp "Choice: " c; [[ "''${c:-1}" == "2" ]] && FS="ext4" || FS="btrfs"

        echo "WARNING: This DESTROYS all data on $DISK"
        echo "Layout: EFI ''${BOOT_SIZE} + root (remaining), zram for swap"
        read -rp "Type 'yes' to confirm: " ok; [[ $ok == "yes" ]] || exit 1

        umount -R "$MNT" 2>/dev/null || true
        sgdisk --zap-all "$DISK" && wipefs -a "$DISK"

        sgdisk \
          --new=1:0:"+''${BOOT_SIZE}" --typecode=1:EF00 --change-name=1:nixos-boot \
          --new=2:0:0               --typecode=2:8300 --change-name=2:nixos-root \
          "$DISK"
        partprobe "$DISK" && sleep 1

        for label in nixos-boot nixos-root; do
          for i in {1..20}; do
            [[ -e "/dev/disk/by-partlabel/$label" ]] && break
            sleep 0.5
          done
          [[ -e "/dev/disk/by-partlabel/$label" ]] || { echo "Missing: $label"; exit 1; }
        done

        BOOT="/dev/disk/by-partlabel/nixos-boot"
        ROOT="/dev/disk/by-partlabel/nixos-root"
        wipefs -a "$BOOT" "$ROOT"

        mkfs.fat -F32 -n nixos-boot "$BOOT"

        if [[ $FS == "btrfs" ]]; then
          mkfs.btrfs -f -L nixos-root "$ROOT"
          mount "$ROOT" "$MNT"
          for sv in @ @home @nix @tmp @log; do btrfs subvolume create "$MNT/$sv"; done
          umount "$MNT"
          OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"
          mount -t btrfs -o "subvol=/@,$OPTS" "$ROOT" "$MNT"
          mkdir -p "$MNT"/{home,nix,var/tmp,var/log,boot}
          mount -t btrfs -o "subvol=/@home,$OPTS" "$ROOT" "$MNT/home"
          mount -t btrfs -o "subvol=/@nix,$OPTS"  "$ROOT" "$MNT/nix"
          mount -t btrfs -o "subvol=/@tmp,$OPTS"  "$ROOT" "$MNT/var/tmp"
          mount -t btrfs -o "subvol=/@log,$OPTS"  "$ROOT" "$MNT/var/log"
          mount -o umask=0077 "$BOOT" "$MNT/boot"
        else
          mkfs.ext4 -L nixos-root -E lazy_itable_init=0,lazy_journal_init=0 "$ROOT"
          mount -t ext4 -o noatime,errors=remount-ro "$ROOT" "$MNT"
          mkdir -p "$MNT/boot"
          mount -o umask=0077 "$BOOT" "$MNT/boot"
        fi

        echo "✓ Done. Layout:"; lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"
        echo "Next: make install-nixos HOST=<host>"
      '';
    };

    mount-rescue = mkLinuxApp "mount-rescue" {
      runtimeInputs = with pkgs; [util-linux btrfs-progs];
      text = ''
        MNT="''${1:-/mnt}"
        FS="$(blkid -s TYPE -o value /dev/disk/by-label/nixos-root 2>/dev/null || echo ext4)"
        echo "Detected: $FS"
        ${mountRootScript "$FS"}
        echo "Mounted at $MNT. Enter with: sudo nixos-enter --root $MNT"
      '';
    };

    troubleshoot = mkLinuxApp "troubleshoot" {
      runtimeInputs = with pkgs; [util-linux btrfs-progs nixos-install-tools];
      text = ''
        MNT="''${1:-/mnt}"
        FS="$(blkid -s TYPE -o value /dev/disk/by-label/nixos-root 2>/dev/null || echo ext4)"
        echo "Detected: $FS"
        ${mountRootScript "$FS"}
        echo "Entering NixOS..."; exec nixos-enter --root "$MNT"
      '';
    };
  }
