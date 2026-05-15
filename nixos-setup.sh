#!/usr/bin/env bash

set -euxo pipefail
shopt -s inherit_errexit 2>/dev/null || true

DISK="$1"
MODE="$2"
BOOT_PART=""
ROOT_PART=""
MOUNTED=0

cleanup() {
  [[ $MOUNTED -eq 1 ]] || return 0
  swapoff /mnt/var/swapfile 2>/dev/null || true
  umount -R /mnt 2>/dev/null || true
}
trap cleanup EXIT

[[ $EUID -ne 0 ]]        && { echo "must be root" >&2; exit 1; }
[[ $# -ne 2 ]]            && { echo "usage: $0 <disk> <install|rescue>" >&2; exit 1; }
[[ ! -b "$DISK" ]]        && { echo "not a block device: $DISK" >&2; exit 1; }
[[ "$MODE" != "install" && "$MODE" != "rescue" ]] && { echo "mode must be install or rescue" >&2; exit 1; }

if [[ "$DISK" =~ (nvme|mmcblk)[0-9] ]]; then
  BOOT_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
else
  BOOT_PART="${DISK}1"
  ROOT_PART="${DISK}2"
fi

# safety checks
root_disk=$(lsblk -ndo PKNAME "$(findmnt -n -o SOURCE /)" 2>/dev/null || true)
[[ "/dev/$root_disk" == "$DISK" ]] && { echo "refusing to operate on booted disk" >&2; exit 1; }
lsblk -n -o MOUNTPOINTS "$DISK" | grep -qE '\S' && { echo "disk has active mounts" >&2; exit 1; }

if [[ "$MODE" == "rescue" ]]; then
  [[ ! -b "$BOOT_PART" || ! -b "$ROOT_PART" ]] && { echo "rescue requires existing partitions" >&2; exit 1; }
fi

read -r -p "wipe $DISK and $MODE? type yes: " confirm
[[ "$confirm" != "yes" ]] && exit 0

mount_subvolumes() {
  mount -o subvol=@ "$ROOT_PART" /mnt
  MOUNTED=1
  mkdir -p /mnt/{home,nix,var,boot}
  mount -o subvol=@home "$ROOT_PART" /mnt/home
  mount -o subvol=@nix  "$ROOT_PART" /mnt/nix
  mount -o subvol=@var  "$ROOT_PART" /mnt/var
  mount "$BOOT_PART" /mnt/boot
}

if [[ "$MODE" == "install" ]]; then
  for cmd in parted mkfs.vfat mkfs.btrfs btrfs nixos-generate-config nixos-install; do
    command -v "$cmd" &>/dev/null || { echo "missing: $cmd" >&2; exit 1; }
  done

  parted "$DISK" --script -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary 513MiB 100%

  partprobe "$DISK" 2>/dev/null || true
  udevadm settle

  mkfs.vfat -F32 -n "NIX-BOOT" "$BOOT_PART"
  mkfs.btrfs -f -L "nix-root" "$ROOT_PART"

  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@var
  umount /mnt

  mount_subvolumes

  if btrfs filesystem mkswapfile --size 7G /mnt/var/swapfile 2>/dev/null; then
    :
  else
    truncate -s 0 /mnt/var/swapfile
    chattr +C /mnt/var/swapfile 2>/dev/null || true
    dd if=/dev/zero of=/mnt/var/swapfile bs=1M count=7168 status=progress
    mkswap /mnt/var/swapfile
  fi
  chmod 600 /mnt/var/swapfile
  swapon /mnt/var/swapfile || true

  nixos-generate-config --root /mnt

  if [[ -f flake.nix ]]; then
    flake_host=$(grep -oP '(?<=hostName = ").*(?=")' /mnt/etc/nixos/hardware-configuration.nix 2>/dev/null | head -1 || echo "nixos")
    [[ -z "$flake_host" ]] && flake_host="nixos"
    nixos-install --flake ".#${flake_host}" --no-root-passwd
  else
    nixos-install --no-root-passwd
  fi

else
  for cmd in btrfs nixos-enter; do
    command -v "$cmd" &>/dev/null || { echo "missing: $cmd" >&2; exit 1; }
  done

  mount_subvolumes
  swapon /mnt/var/swapfile 2>/dev/null || true
  nixos-enter
fi
