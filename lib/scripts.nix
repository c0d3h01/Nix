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
      runtimeInputs = with pkgs; [
        util-linux # wipefs, blkid, mkswap, swapon, findmnt
        dosfstools # mkfs.fat
        btrfs-progs # mkfs.btrfs, btrfs
        e2fsprogs # mkfs.ext4, chattr
        gptfdisk # sgdisk, partprobe
        coreutils # truncate, fallocate, chmod, etc.
        zfs # zpool, zfs, zgenhostid
      ];
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

        echo "Choose filesystem for root partition:"
        echo "  [1] btrfs (default) — recommended, best feature set"
        echo "  [2] ext4            — simple, stable fallback"
        echo "  [3] zfs             — advanced, requires more RAM"
        read -rp "Enter choice [1/2/3]: " fs_choice
        case "''${fs_choice:-1}" in
          2) FS_TYPE="ext4" ;;
          3) FS_TYPE="zfs" ;;
          *) FS_TYPE="btrfs" ;;
        esac
        echo "-> Using: ''${FS_TYPE}"
        echo ""

        echo "WARNING: This will DESTROY all data on ''${DISK}"
        echo ""
        echo "  Partition layout:"
        echo "    1  nixos-boot  ''${BOOT_SIZE}   FAT32 (EFI)"
        echo "    2  nixos-root  remaining  ''${FS_TYPE}"
        echo "  (no swap partition — zram-generator handles swap at runtime)"
        echo ""
        read -rp "Type 'yes' to continue: " confirm
        if [[ $confirm != "yes" ]]; then
          echo "Aborted."
          exit 1
        fi

        # Unmount anything currently mounted under the target mountpoint.
        echo "Unmounting ''${MNT}..."
        umount -R "$MNT" 2>/dev/null || true

        # Release any existing ZFS pool holding a claim on the disk.
        # Must happen before wipefs or zpool create will error.
        echo "Releasing any existing ZFS pool..."
        zpool export zpool 2>/dev/null || true

        echo "Wiping partition table and filesystem signatures on ''${DISK}..."
        sgdisk --zap-all "$DISK"
        # sgdisk destroys the partition table but leaves filesystem superblocks
        # (btrfs, ext4, ZFS) at their on-disk offsets. Wipe them explicitly so
        # no tool can misdetect old data on the raw device.
        wipefs -a "$DISK"

        echo "Creating new GPT partition table..."
        sgdisk \
          --new=1:0:"+''${BOOT_SIZE}" --typecode=1:EF00 --change-name=1:nixos-boot \
          --new=2:0:0               --typecode=2:8300 --change-name=2:nixos-root \
          "$DISK"

        sleep 1
        partprobe "$DISK"
        sleep 1

        # Wait for udev to expose partition symlinks before we use them.
        wait_for_label() {
          local label="$1" attempts=0
          while [[ ! -e "/dev/disk/by-partlabel/''${label}" ]] && ((attempts < 20)); do
            sleep 0.5
            ((attempts++))
          done
          if [[ ! -e "/dev/disk/by-partlabel/''${label}" ]]; then
            echo "Error: partition label ''${label} not found after 10s"
            exit 1
          fi
        }

        wait_for_label "nixos-boot"
        wait_for_label "nixos-root"

        PART_BOOT="/dev/disk/by-partlabel/nixos-boot"
        PART_ROOT="/dev/disk/by-partlabel/nixos-root"

        # Wipe partition-level superblocks too. btrfs writes a backup superblock
        # near the end of the partition; when the partition boundary aligns with
        # the old one, it survives the whole-disk wipe above and causes ZFS to
        # refuse creation even with a clean GPT.
        echo "Wiping filesystem signatures on partitions..."
        wipefs -a "$PART_BOOT"
        wipefs -a "$PART_ROOT"

        echo "Formatting EFI partition..."
        mkfs.fat -F 32 -n nixos-boot "$PART_BOOT"

        if [[ $FS_TYPE == "btrfs" ]]; then
          echo "Formatting root as btrfs..."
          mkfs.btrfs -f -L nixos-root "$PART_ROOT"

          # Create subvolumes for granular snapshot and mount control.
          mount "$PART_ROOT" "$MNT"
          btrfs subvolume create "''${MNT}/@"
          btrfs subvolume create "''${MNT}/@home"
          btrfs subvolume create "''${MNT}/@nix"
          btrfs subvolume create "''${MNT}/@tmp"
          btrfs subvolume create "''${MNT}/@log"
          umount "$MNT"

          BTRFS_OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

          echo "Mounting btrfs subvolumes..."
          mount -t btrfs -o "subvol=/@,''${BTRFS_OPTS}"     "$PART_ROOT" "$MNT"
          mkdir -p "''${MNT}"/{home,nix,var/tmp,var/log,boot}
          mount -t btrfs -o "subvol=/@home,''${BTRFS_OPTS}" "$PART_ROOT" "''${MNT}/home"
          mount -t btrfs -o "subvol=/@nix,''${BTRFS_OPTS}"  "$PART_ROOT" "''${MNT}/nix"
          mount -t btrfs -o "subvol=/@tmp,''${BTRFS_OPTS}"  "$PART_ROOT" "''${MNT}/var/tmp"
          mount -t btrfs -o "subvol=/@log,''${BTRFS_OPTS}"  "$PART_ROOT" "''${MNT}/var/log"
          mount -o umask=0077 "$PART_BOOT" "''${MNT}/boot"

        elif [[ $FS_TYPE == "zfs" ]]; then
          POOL_NAME="zpool"

          # Derive hostid using the same algorithm as mkHost.nix:
          #   builtins.substring 0 8 (builtins.hashString "md5" hostname)
          # The -n flag is critical — without it, echo appends a newline and
          # produces a different hash than Nix, breaking ZFS import at boot.
          HOST_ID="$(echo -n "$(hostname)" | md5sum | cut -c1-8)"

          echo "Creating ZFS pool '''${POOL_NAME}'..."
          zpool create \
            -o ashift=12 \
            -o autotrim=on \
            -O acltype=posixacl \
            -O compression=zstd \
            -O dnodesize=auto \
            -O normalization=formD \
            -O relatime=on \
            -O xattr=sa \
            -O mountpoint=none \
            -R "$MNT" \
            "$POOL_NAME" "$PART_ROOT"

          echo "Creating ZFS datasets..."
          # mountpoint=legacy hands mount control to /etc/fstab (NixOS fileSystems).
          zfs create -o mountpoint=legacy                        "$POOL_NAME/root"
          zfs create -o mountpoint=legacy                        "$POOL_NAME/home"
          zfs create -o mountpoint=legacy \
                     -o com.sun:auto-snapshot=false              "$POOL_NAME/nix"
          zfs create -o mountpoint=legacy                        "$POOL_NAME/log"

          # Write hostid so NixOS can verify pool ownership at boot.
          # boot.zfs.forceImportRoot = false in zfs.nix relies on this matching.
          echo "Setting hostid to ''${HOST_ID}..."
          zgenhostid "$HOST_ID"

          echo "Mounting ZFS datasets..."
          mount -t zfs "$POOL_NAME/root" "$MNT"
          mkdir -p "$MNT"/{home,nix,var/log,boot}
          mount -t zfs "$POOL_NAME/home" "$MNT/home"
          mount -t zfs "$POOL_NAME/nix"  "$MNT/nix"
          mount -t zfs "$POOL_NAME/log"  "$MNT/var/log"
          mount -o umask=0077 "$PART_BOOT" "$MNT/boot"

        else
          echo "Formatting root as ext4..."
          mkfs.ext4 -L nixos-root \
            -E lazy_itable_init=0,lazy_journal_init=0 \
            "$PART_ROOT"

          echo "Mounting ext4 root..."
          mount -t ext4 -o noatime,discard,errors=remount-ro "$PART_ROOT" "$MNT"
          mkdir -p "''${MNT}/boot"
          mount -o umask=0077 "$PART_BOOT" "''${MNT}/boot"
        fi

        echo ""
        echo "Done! Partition layout:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"
        echo ""
        echo "Next: make swap-on (btrfs/ext4 only) then make install-nixos HOST=<host>"
      '';
    };

    mount-rescue = writeShellApplication {
      name = "mount-rescue";
      runtimeInputs = with pkgs; [util-linux btrfs-progs coreutils zfs];
      text = ''
        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        MNT="''${1:-/mnt}"

        # Detect filesystem type from the partition label rather than guessing.
        FS="$(blkid -s TYPE -o value /dev/disk/by-label/nixos-root 2>/dev/null || true)"
        echo "Detected filesystem: ''${FS:-unknown}"

        if [[ $FS == "zfs_member" ]]; then
          echo "Importing ZFS pool to ''${MNT}..."
          # -f overrides hostid mismatch (expected when booting a live ISO).
          # -R sets the pool's temporary mountpoint root so datasets land under $MNT.
          zpool import -f -R "$MNT" zpool
          mount -t zfs zpool/root "$MNT"
          mkdir -p "$MNT"/{home,nix,var/log,boot}
          mount -t zfs zpool/home "$MNT/home"
          mount -t zfs zpool/nix  "$MNT/nix"
          mount -t zfs zpool/log  "$MNT/var/log"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"

        elif [[ $FS == "btrfs" ]]; then
          echo "Mounting btrfs subvolumes to ''${MNT}..."
          mount -t btrfs -o subvol=/@ /dev/disk/by-label/nixos-root "$MNT"
          mkdir -p "$MNT"/{home,nix,var/tmp,var/log,boot}
          mount -t btrfs -o subvol=/@home /dev/disk/by-label/nixos-root "$MNT/home"
          mount -t btrfs -o subvol=/@nix  /dev/disk/by-label/nixos-root "$MNT/nix"
          mount -t btrfs -o subvol=/@tmp  /dev/disk/by-label/nixos-root "$MNT/var/tmp"
          mount -t btrfs -o subvol=/@log  /dev/disk/by-label/nixos-root "$MNT/var/log"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"

        else
          echo "Mounting ext4 root to ''${MNT}..."
          mount -t ext4 -o noatime,errors=remount-ro \
            /dev/disk/by-label/nixos-root "$MNT"
          mkdir -p "$MNT/boot"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"
        fi

        echo ""
        echo "All filesystems mounted at ''${MNT}"
        echo "Run: sudo nixos-enter --root $MNT"
      '';
    };

    troubleshoot = writeShellApplication {
      name = "troubleshoot";
      runtimeInputs = with pkgs; [util-linux btrfs-progs coreutils zfs nixos-install-tools];
      text = ''
        MNT="''${1:-/mnt}"

        if [[ $EUID -ne 0 ]]; then
          echo "Error: must run as root"
          exit 1
        fi

        FS="$(blkid -s TYPE -o value /dev/disk/by-label/nixos-root 2>/dev/null || true)"
        echo "Detected filesystem: ''${FS:-unknown}"
        echo "Mounting rescue environment at ''${MNT}..."

        if [[ $FS == "zfs_member" ]]; then
          zpool import -f -R "$MNT" zpool
          mount -t zfs zpool/root "$MNT"
          mkdir -p "$MNT"/{home,nix,var/log,boot}
          mount -t zfs zpool/home "$MNT/home"
          mount -t zfs zpool/nix  "$MNT/nix"
          mount -t zfs zpool/log  "$MNT/var/log"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"

        elif [[ $FS == "btrfs" ]]; then
          mount -t btrfs -o subvol=/@ /dev/disk/by-label/nixos-root "$MNT"
          mkdir -p "$MNT"/{home,nix,var/tmp,var/log,boot}
          mount -t btrfs -o subvol=/@home /dev/disk/by-label/nixos-root "$MNT/home"
          mount -t btrfs -o subvol=/@nix  /dev/disk/by-label/nixos-root "$MNT/nix"
          mount -t btrfs -o subvol=/@tmp  /dev/disk/by-label/nixos-root "$MNT/var/tmp"
          mount -t btrfs -o subvol=/@log  /dev/disk/by-label/nixos-root "$MNT/var/log"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"

        else
          mount -t ext4 -o noatime,errors=remount-ro \
            /dev/disk/by-label/nixos-root "$MNT"
          mkdir -p "$MNT/boot"
          mount /dev/disk/by-label/nixos-boot "$MNT/boot"
        fi

        echo "Entering NixOS environment..."
        nixos-enter --root "$MNT"
      '';
    };
  }
