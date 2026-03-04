#!/usr/bin/env bash
#
# Usage:   sudo ./scripts/partition.sh /dev/nvme0n1   (or /dev/sda, etc.)
#
# Partition table (GPT):
#   1  nixos-boot   1 GiB   EFI System (FAT32)
#   2  nixos-swap   8 GiB   Linux swap
#   3  nixos-root   rest    Btrfs with subvolumes
#
# Btrfs subvolumes on nixos-root:
#   /@      → /
#   /@home  → /home
#   /@nix   → /nix
#   /@tmp   → /var/tmp
#   /@log   → /var/log

set -euo pipefail

DISK="${1:-}"
MNT="${2:-/mnt}"
SWAP_SIZE="${SWAP_SIZE:-8G}"
BOOT_SIZE="${BOOT_SIZE:-1G}"

if [[ -z $DISK ]]; then
  echo "Usage: sudo $0 <disk> [mountpoint]"
  echo "  e.g. sudo $0 /dev/nvme0n1"
  echo "  e.g. sudo $0 /dev/sda /mnt"
  echo ""
  echo "Environment variables:"
  echo "  SWAP_SIZE  swap partition size (default: 8G)"
  echo "  BOOT_SIZE  EFI partition size  (default: 1G)"
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

echo "WARNING: This will DESTROY all data on ${DISK}"
echo ""
echo "  Partition layout:"
echo "    1  nixos-boot  ${BOOT_SIZE}   FAT32 (EFI)"
echo "    2  nixos-swap  ${SWAP_SIZE}   swap"
echo "    3  nixos-root  remaining  Btrfs"
echo ""
read -rp "Type 'yes' to continue: " confirm
if [[ $confirm != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

echo ":: Unmounting any existing mounts on ${DISK}..."
umount -R "$MNT" 2>/dev/null || true
swapoff "${DISK}"* 2>/dev/null || true

echo ":: Partitioning ${DISK}..."
sgdisk --zap-all "$DISK"

sgdisk \
  --new=1:0:"+${BOOT_SIZE}" --typecode=1:EF00 --change-name=1:nixos-boot \
  --new=2:0:"+${SWAP_SIZE}" --typecode=2:8200 --change-name=2:nixos-swap \
  --new=3:0:0 --typecode=3:8300 --change-name=3:nixos-root \
  "$DISK"

sleep 1
partprobe "$DISK"
sleep 1

wait_for_label() {
  local label="$1" attempts=0
  while [[ ! -e "/dev/disk/by-partlabel/${label}" ]] && ((attempts < 20)); do
    sleep 0.5
    ((attempts++))
  done
  if [[ ! -e "/dev/disk/by-partlabel/${label}" ]]; then
    echo "Error: partition label '${label}' not found after waiting"
    exit 1
  fi
}

wait_for_label "nixos-boot"
wait_for_label "nixos-swap"
wait_for_label "nixos-root"

PART_BOOT="/dev/disk/by-partlabel/nixos-boot"
PART_SWAP="/dev/disk/by-partlabel/nixos-swap"
PART_ROOT="/dev/disk/by-partlabel/nixos-root"

echo ":: Formatting partitions..."

mkfs.fat -F 32 -n NIXBOOT "$PART_BOOT"
mkswap -L nixos-swap "$PART_SWAP"
mkfs.btrfs -f -L nixos-root "$PART_ROOT"

echo ":: Creating Btrfs subvolumes..."

mount "$PART_ROOT" "$MNT"
btrfs subvolume create "${MNT}/@"
btrfs subvolume create "${MNT}/@home"
btrfs subvolume create "${MNT}/@nix"
btrfs subvolume create "${MNT}/@tmp"
btrfs subvolume create "${MNT}/@log"
umount "$MNT"

echo ":: Mounting filesystems..."

BTRFS_OPTS="noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

mount -t btrfs -o "subvol=/@,${BTRFS_OPTS}" "$PART_ROOT" "$MNT"

mkdir -p "${MNT}/home" "${MNT}/nix" "${MNT}/var/tmp" "${MNT}/var/log" "${MNT}/boot"

mount -t btrfs -o "subvol=/@home,${BTRFS_OPTS}" "$PART_ROOT" "${MNT}/home"
mount -t btrfs -o "subvol=/@nix,${BTRFS_OPTS}" "$PART_ROOT" "${MNT}/nix"
mount -t btrfs -o "subvol=/@tmp,${BTRFS_OPTS}" "$PART_ROOT" "${MNT}/var/tmp"
mount -t btrfs -o "subvol=/@log,${BTRFS_OPTS}" "$PART_ROOT" "${MNT}/var/log"

mount -o umask=0077 "$PART_BOOT" "${MNT}/boot"

swapon "$PART_SWAP"

echo ""
echo "Done! Partition layout:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"
echo ""
echo "Next steps:"
echo "  sudo nixos-install --flake <flake>#<host> --no-root-passwd"
