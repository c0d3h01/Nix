# scripts as nix packages, exposed via flake.outputs.packages
{pkgs}: let
  inherit (pkgs) writeShellApplication;
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
  {
    install-nix = writeShellApplication {
      name = "install-nix";
      runtimeInputs = with pkgs; [curl];
      text = ''
        echo "Installing Nix package manager (multi-user)..."
        curl -L https://nixos.org/nix/install | sh -s -- --daemon
      '';
    };
  }
  // lib.optionalAttrs isLinux {
    partition = writeShellApplication {
      name = "partition";
      runtimeInputs = with pkgs; [util-linux dosfstools btrfs-progs gptfdisk coreutils];
      text = ''
        DISK="''${1:-}"
        MNT="''${2:-/mnt}"
        BOOT_SIZE="''${BOOT_SIZE:-1G}"

        if [[ -z $DISK ]]; then
          echo "Usage: partition <disk> [mountpoint]"
          echo "  e.g. partition /dev/nvme0n1"
          echo ""
          echo "Environment variables:"
          echo "  BOOT_SIZE  EFI partition size (default: 1G)"
          exit 1
        fi

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        if [[ ! -b $DISK ]]; then
          echo "Error: $DISK is not a block device"
          exit 1
        fi

        echo "WARNING: This will DESTROY all data on ''${DISK}"
        echo ""
        echo "  Partition layout:"
        echo "    1  nixos-boot  ''${BOOT_SIZE}   FAT32 (EFI)"
        echo "    2  nixos-root  remaining  Btrfs"
        echo "  (no swap partition — zram-generator handles swap at runtime)"
        echo "  (a temporary 4G swapfile is created for installation only)"
        echo ""
        read -rp "Type 'yes' to continue: " confirm
        if [[ $confirm != "yes" ]]; then
          echo "Aborted."
          exit 1
        fi

        umount -R "$MNT" 2>/dev/null || true

        sgdisk --zap-all "$DISK"
        sgdisk \
          --new=1:0:"+''${BOOT_SIZE}" --typecode=1:EF00 --change-name=1:nixos-boot \
          --new=2:0:0 --typecode=2:8300 --change-name=2:nixos-root \
          "$DISK"

        sleep 1
        partprobe "$DISK"
        sleep 1

        wait_for_label() {
          local label="$1" attempts=0
          while [[ ! -e "/dev/disk/by-partlabel/''${label}" ]] && ((attempts < 20)); do
            sleep 0.5
            ((attempts++))
          done
          if [[ ! -e "/dev/disk/by-partlabel/''${label}" ]]; then
            echo "Error: partition label ''\'''${label}' not found after waiting"
            exit 1
          fi
        }

        wait_for_label "nixos-boot"
        wait_for_label "nixos-root"

        PART_BOOT="/dev/disk/by-partlabel/nixos-boot"
        PART_ROOT="/dev/disk/by-partlabel/nixos-root"

        mkfs.fat -F 32 -n NIXBOOT "$PART_BOOT"
        mkfs.btrfs -f -L nixos-root "$PART_ROOT"

        mount "$PART_ROOT" "$MNT"
        btrfs subvolume create "''${MNT}/@"
        btrfs subvolume create "''${MNT}/@home"
        btrfs subvolume create "''${MNT}/@nix"
        btrfs subvolume create "''${MNT}/@tmp"
        btrfs subvolume create "''${MNT}/@log"
        umount "$MNT"

        BTRFS_OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

        mount -t btrfs -o "subvol=/@,''${BTRFS_OPTS}" "$PART_ROOT" "$MNT"
        mkdir -p "''${MNT}/home" "''${MNT}/nix" "''${MNT}/var/tmp" "''${MNT}/var/log" "''${MNT}/boot"
        mount -t btrfs -o "subvol=/@home,''${BTRFS_OPTS}" "$PART_ROOT" "''${MNT}/home"
        mount -t btrfs -o "subvol=/@nix,''${BTRFS_OPTS}" "$PART_ROOT" "''${MNT}/nix"
        mount -t btrfs -o "subvol=/@tmp,''${BTRFS_OPTS}" "$PART_ROOT" "''${MNT}/var/tmp"
        mount -t btrfs -o "subvol=/@log,''${BTRFS_OPTS}" "$PART_ROOT" "''${MNT}/var/log"
        mount -o umask=0077 "$PART_BOOT" "''${MNT}/boot"

        echo ""
        echo "Done! Partition layout:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"
        echo ""
        echo "Next: make swap (optional) then make install-nixos HOST=<host>"
      '';
    };

    mount-rescue = writeShellApplication {
      name = "mount-rescue";
      runtimeInputs = with pkgs; [util-linux btrfs-progs coreutils];
      text = ''
        MNT="''${1:-/mnt}"

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        echo "Mounting BTRFS subvolumes + EFI to ''${MNT}..."

        mount -t btrfs -o subvol=/@ /dev/disk/by-label/nixos-root "$MNT"
        mkdir -p "$MNT/home" "$MNT/nix" "$MNT/var/tmp" "$MNT/var/log" "$MNT/boot"
        mount -t btrfs -o subvol=/@home /dev/disk/by-label/nixos-root "$MNT/home"
        mount -t btrfs -o subvol=/@nix /dev/disk/by-label/nixos-root "$MNT/nix"
        mount -t btrfs -o subvol=/@tmp /dev/disk/by-label/nixos-root "$MNT/var/tmp"
        mount -t btrfs -o subvol=/@log /dev/disk/by-label/nixos-root "$MNT/var/log"
        mount /dev/disk/by-label/NIXBOOT "$MNT/boot"

        echo "All subvolumes mounted at ''${MNT}"
        echo "Run: sudo nixos-enter --root $MNT"
      '';
    };

    troubleshoot = writeShellApplication {
      name = "troubleshoot";
      runtimeInputs = with pkgs; [util-linux btrfs-progs coreutils nixos-install-tools];
      text = ''
        MNT="''${1:-/mnt}"

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        echo "Mounting rescue environment at ''${MNT}..."

        mount -t btrfs -o subvol=/@ /dev/disk/by-label/nixos-root "$MNT"
        mkdir -p "$MNT/home" "$MNT/nix" "$MNT/var/tmp" "$MNT/var/log" "$MNT/boot"
        mount -t btrfs -o subvol=/@home /dev/disk/by-label/nixos-root "$MNT/home"
        mount -t btrfs -o subvol=/@nix /dev/disk/by-label/nixos-root "$MNT/nix"
        mount -t btrfs -o subvol=/@tmp /dev/disk/by-label/nixos-root "$MNT/var/tmp"
        mount -t btrfs -o subvol=/@log /dev/disk/by-label/nixos-root "$MNT/var/log"
        mount /dev/disk/by-label/NIXBOOT "$MNT/boot"

        echo "Entering NixOS environment..."
        nixos-enter --root "$MNT"
      '';
    };

    swap-on = writeShellApplication {
      name = "swap-on";
      runtimeInputs = with pkgs; [util-linux coreutils e2fsprogs];
      text = ''
        MNT="''${1:-/mnt}"
        SIZE="''${2:-4G}"
        SWAPFILE="''${MNT}/swapfile"

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        echo "Creating ''${SIZE} swapfile at ''${SWAPFILE}..."
        truncate -s 0 "$SWAPFILE"
        chattr +C "$SWAPFILE" 2>/dev/null || true
        fallocate -l "$SIZE" "$SWAPFILE"
        chmod 600 "$SWAPFILE"
        mkswap "$SWAPFILE"
        swapon "$SWAPFILE"
        echo "Swapfile active. Remove with: make swap-off"
      '';
    };

    swap-off = writeShellApplication {
      name = "swap-off";
      runtimeInputs = with pkgs; [util-linux coreutils];
      text = ''
        MNT="''${1:-/mnt}"
        SWAPFILE="''${MNT}/swapfile"

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        if [[ -f $SWAPFILE ]]; then
          swapoff "$SWAPFILE" 2>/dev/null || true
          rm -f "$SWAPFILE"
          echo "Swapfile removed."
        else
          echo "No swapfile found at ''${SWAPFILE}"
        fi
      '';
    };
  }
