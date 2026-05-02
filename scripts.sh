#!/usr/bin/env bash

set -euo pipefail

DISK="${1:-}"
MODE="${2:-install}"

BOOT=""
ROOT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Error handling
error_exit() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

check_args() {
  if [ -z "$DISK" ]; then
    error_exit "No disk specified. Usage: $0 /dev/sdX [install|rescue]"
  fi
  if [ ! -b "$DISK" ]; then
    error_exit "Disk $DISK does not exist or is not a block device."
  fi
  BOOT="${DISK}p1"
  ROOT="${DISK}p2"
}

partition_disk() {
  echo -e "${GREEN}Partitioning disk $DISK...${NC}"
  parted "$DISK" --script -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary 513MiB 100%
}

format_fs() {
  echo -e "${GREEN}Formatting partitions...${NC}"
  mkfs.vfat -F32 -n "NIX-BOOT" "$BOOT"
  mkfs.btrfs -f -L "nix-root" "$ROOT"
}

create_subvols() {
  echo -e "${GREEN}Creating Btrfs subvolumes...${NC}"
  mount "$ROOT" /mnt || error_exit "Failed to mount $ROOT to /mnt"
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@var
}

mount_fs() {
  echo -e "${GREEN}Mounting filesystems...${NC}"
  umount /mnt 2>/dev/null || true

  mount -o subvol=@,noatime,compress=zstd:3 "$ROOT" /mnt
  mkdir -p /mnt/{home,nix,var,boot}

  mount -o subvol=@home,noatime,compress=zstd:3 "$ROOT" /mnt/home
  mount -o subvol=@nix,noatime,compress=zstd:3 "$ROOT" /mnt/nix
  mount -o subvol=@var,noatime,compress=zstd:3 "$ROOT" /mnt/var
  mount "$BOOT" /mnt/boot
}

create_swap() {
  echo -e "${GREEN}Creating swapfile...${NC}"
  btrfs filesystem mkswapfile --size 7G /mnt/var/swapfile
  swapon /mnt/var/swapfile
}

generate_nixos() {
  echo -e "${GREEN}Generating NixOS configuration...${NC}"
  nixos-generate-config --root /mnt
}

install_nixos() {
  echo -e "${GREEN}Installing NixOS...${NC}"
  nixos-install --flake ".#nixos" --no-root-passwd
}

rescue_mode() {
  echo -e "${GREEN}Entering rescue mode...${NC}"
  mount -o subvol=@,noatime,compress=zstd:3 "$ROOT" /mnt
  mkdir -p /mnt/{home,nix,var,boot}

  mount -o subvol=@home,noatime,compress=zstd:3 "$ROOT" /mnt/home
  mount -o subvol=@nix,noatime,compress=zstd:3 "$ROOT" /mnt/nix
  mount -o subvol=@var,noatime,compress=zstd:3 "$ROOT" /mnt/var
  mount "$BOOT" /mnt/boot

  swapon /mnt/var/swapfile 2>/dev/null || true

  mount --bind /dev /mnt/dev
  mount --bind /proc /mnt/proc
  mount --bind /sys /mnt/sys
  mount --bind /run /mnt/run

  # optional but useful
  mkdir -p /mnt/etc
  cp /etc/resolv.conf /mnt/etc/resolv.conf

  echo -e "${GREEN}Entering nixos-enter...${NC}"
  nixos-enter
}

install_mode() {
  partition_disk
  format_fs
  create_subvols
  mount_fs
  create_swap
  generate_nixos
  install_nixos
}

main() {
  check_args
  if [ "$MODE" = "rescue" ]; then
    rescue_mode
  else
    install_mode
  fi
}

main
