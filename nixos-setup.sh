#!/usr/bin/env bash

set -euxo pipefail
shopt -s inherit_errexit 2>/dev/null || true

readonly SCRIPT_NAME="$(basename "$0")"
readonly REQUIRED_CMDS=(parted mkfs.vfat mkfs.btrfs btrfs nixos-generate-config nixos-install nixos-enter)

DISK=""
MODE=""
BOOT_PART=""
ROOT_PART=""

cleanup() {
  local code=$?
  swapoff /mnt/var/swapfile 2>/dev/null || true
  umount -R /mnt 2>/dev/null || true
  [[ $code -ne 0 ]] && echo "Script exited with code $code. Verify mounts manually if needed." >&2
}
trap cleanup EXIT

usage() {
  echo "Usage: $SCRIPT_NAME <BLOCK_DEVICE> <install|rescue>"
  echo "  BLOCK_DEVICE  Target disk (e.g., /dev/nvme0n1, /dev/sda)"
  echo "  MODE          'install' for fresh setup, 'rescue' to chroot"
  exit 1
}

check_dependencies() {
  for cmd in "${REQUIRED_CMDS[@]}"; do
    command -v "$cmd" &>/dev/null || { echo "Missing required command: $cmd" >&2; exit 1; }
  done
}

check_root() {
  [[ $EUID -ne 0 ]] && { echo "This script must be run as root." >&2; exit 1; }
}

set_partition_names() {
  local disk="$1"
  if [[ "$disk" =~ (nvme|mmcblk)[0-9] ]]; then
    BOOT_PART="${disk}p1"
    ROOT_PART="${disk}p2"
  else
    BOOT_PART="${disk}1"
    ROOT_PART="${disk}2"
  fi
}

parse_args() {
  [[ $# -lt 2 ]] && usage
  DISK="$1"
  MODE="$2"

  [[ ! -b "$DISK" ]] && { echo "'$DISK' is not a valid block device." >&2; exit 1; }

  if [[ "$DISK" =~ nvme[0-9]+n[0-9]+p[0-9]+$ ]] || \
     [[ "$DISK" =~ mmcblk[0-9]+p[0-9]+$ ]] || \
     [[ "$DISK" =~ [a-z][0-9]+$ && ! "$DISK" =~ nvme && ! "$DISK" =~ mmcblk ]]; then
    echo "Specify the base disk (e.g., /dev/nvme0n1, /dev/sda), not a partition." >&2
    exit 1
  fi

  [[ "$MODE" != "install" && "$MODE" != "rescue" ]] && { echo "Mode must be 'install' or 'rescue'." >&2; exit 1; }

  set_partition_names "$DISK"
}

validate() {
  local root_src root_disk
  root_src=$(findmnt -n -o SOURCE / 2>/dev/null || echo "")
  if [[ -n "$root_src" ]]; then
    root_disk=$(lsblk -ndo PKNAME "$root_src" 2>/dev/null || echo "")
    [[ "/dev/$root_disk" == "$DISK" ]] && { echo "Refusing to operate on the currently booted disk: $DISK" >&2; exit 1; }
  fi

  if lsblk -n -o MOUNTPOINTS "$DISK" | grep -qE '\S'; then
    echo "Disk '$DISK' or its partitions are mounted. Unmount them first." >&2
    exit 1
  fi

  if [[ "$MODE" == "rescue" ]]; then
    [[ ! -b "$BOOT_PART" || ! -b "$ROOT_PART" ]] && { echo "Rescue mode requires existing partitions: $BOOT_PART and $ROOT_PART" >&2; exit 1; }
  else
    lsblk -n "$DISK" | grep -q "part" && echo "WARNING: '$DISK' contains partitions. ALL DATA WILL BE DESTROYED." >&2
  fi

  local prompt
  if [[ "$MODE" == "install" ]]; then
    prompt="This will WIPE '$DISK' and install NixOS. Type 'yes' to continue: "
  else
    prompt="Proceed with '$MODE' on '$DISK'? Type 'yes' to continue: "
  fi

  read -r -p "$prompt" confirm
  [[ "$confirm" != "yes" ]] && { echo "Aborted."; exit 0; }
}

partition_and_format() {
  echo "Partitioning $DISK..."
  parted "$DISK" --script -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary 513MiB 100% || { echo "Partitioning failed." >&2; exit 1; }

  partprobe "$DISK" 2>/dev/null || udevadm settle

  echo "Formatting partitions..."
  mkfs.vfat -F32 -n "NIX-BOOT" "$BOOT_PART" || { echo "Boot format failed." >&2; exit 1; }
  mkfs.btrfs -f -L "nix-root" "$ROOT_PART"  || { echo "Root format failed." >&2; exit 1; }
}

create_subvolumes() {
  echo "Creating Btrfs subvolumes..."
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@var
  umount /mnt
}

mount_subvolumes() {
  echo "Mounting filesystems..."
  mount -o subvol=@ "$ROOT_PART" /mnt
  mkdir -p /mnt/{home,nix,var,boot}
  mount -o subvol=@home "$ROOT_PART" /mnt/home
  mount -o subvol=@nix  "$ROOT_PART" /mnt/nix
  mount -o subvol=@var  "$ROOT_PART" /mnt/var
  mount "$BOOT_PART" /mnt/boot
}

setup_swap() {
  echo "Creating swapfile..."
  if btrfs filesystem mkswapfile --size 7G /mnt/var/swapfile 2>/dev/null; then
    :
  else
    echo "btrfs mkswapfile unavailable, falling back to manual method." >&2
    truncate -s 0 /mnt/var/swapfile
    chattr +C /mnt/var/swapfile 2>/dev/null || true
    fallocate -l 7G /mnt/var/swapfile || dd if=/dev/zero of=/mnt/var/swapfile bs=1M count=7168 status=progress
    mkswap /mnt/var/swapfile || { echo "mkswap failed." >&2; exit 1; }
  fi
  chmod 600 /mnt/var/swapfile
  swapon /mnt/var/swapfile || echo "Swap activation failed, continuing without swap." >&2
}

run_install() {
  partition_and_format
  create_subvolumes
  mount_subvolumes
  setup_swap

  echo "Generating NixOS configuration..."
  nixos-generate-config --root /mnt || { echo "Config generation failed." >&2; exit 1; }

  echo "Installing NixOS..."
  if [[ -f flake.nix ]]; then
    local flake_host
    flake_host=$(grep -oP '(?<=hostName = ").*(?=")' /mnt/etc/nixos/configuration.nix 2>/dev/null | head -1 || echo "")
    [[ -z "$flake_host" ]] && { echo "Could not detect hostname, defaulting flake target to 'nixos'." >&2; flake_host="nixos"; }
    nixos-install --flake ".#${flake_host}" --no-root-passwd || { echo "Flake installation failed." >&2; exit 1; }
  else
    nixos-install --no-root-passwd || { echo "Installation failed." >&2; exit 1; }
  fi
  echo "Installation complete. Reboot when ready."
}

run_rescue() {
  mount_subvolumes
  [[ -f /mnt/var/swapfile ]] && { swapon /mnt/var/swapfile 2>/dev/null || echo "Swapfile found but failed to activate." >&2; }
  echo "Launching nixos-enter. Type 'exit' to return to host."
  nixos-enter || { echo "nixos-enter failed." >&2; exit 1; }
}

main() {
  check_root
  check_dependencies
  parse_args "$@"
  validate

  case "$MODE" in
    install) run_install ;;
    rescue)  run_rescue  ;;
  esac
}

main "$@"
