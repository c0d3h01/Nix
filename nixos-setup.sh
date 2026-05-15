#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2155,SC2015

set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

readonly SCRIPT_NAME
SCRIPT_NAME="$(basename "$0")"

readonly REQUIRED_CMDS=(parted mkfs.vfat mkfs.btrfs btrfs nixos-generate-config nixos-install nixos-enter)

# Colors
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' BLUE='\033[0;34m' NC='\033[0m'

# State
DISK=""
MODE=""
BOOT_PART=""
ROOT_PART=""

log()   { echo -e "${GREEN}[INFO]${NC}  $*" >&2; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*" >&2; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
step()  { echo -e "${BLUE}[STEP]${NC}  $*" >&2; }

cleanup() {
  local code=$?
  [[ $code -ne 0 ]] && warn "Script exited with code $code"
  log "Cleaning up mounts & swap..."
  swapoff /mnt/var/swapfile 2>/dev/null || true
  umount -R /mnt 2>/dev/null || true

  if [[ $code -eq 0 ]]; then
    log "[*] Cleanup complete."
  else
    warn "[!]  Cleanup finished (verify mounts manually if needed)."
  fi
}
trap cleanup EXIT

usage() {
  echo -e "${RED}Usage:${NC} $SCRIPT_NAME <BLOCK_DEVICE> <install|rescue>"
  echo -e "  BLOCK_DEVICE  Target disk (e.g., /dev/nvme0n1, /dev/sda)"
  echo -e "  MODE          'install' for fresh setup, 'rescue' to chroot"
  echo -e "${YELLOW}No defaults. Both arguments are strictly required.${NC}"
  exit 1
}

check_dependencies() {
  for cmd in "${REQUIRED_CMDS[@]}"; do
    command -v "$cmd" &>/dev/null || err "Missing required command: $cmd"
  done
}

check_root() {
  [[ $EUID -ne 0 ]] && err "This script must be run as root."
}

parse_args() {
  [[ $# -lt 2 ]] && usage
  DISK="$1"
  MODE="$2"

  [[ ! -b "$DISK" ]] && err "'$DISK' is not a valid block device."
  [[ "$DISK" =~ [0-9]$ ]] && err "Specify the base disk (e.g., /dev/sda), not a partition."
  [[ "$MODE" != "install" && "$MODE" != "rescue" ]] && err "Mode must be 'install' or 'rescue'."
}

validate() {
  # Prevent targeting the booted disk
  local root_src
  root_src=$(findmnt -n -o SOURCE / 2>/dev/null || echo "")
  if [[ -n "$root_src" ]]; then
    local root_disk
    root_disk=$(lsblk -ndo PKNAME "$root_src" 2>/dev/null || echo "")
    if [[ "/dev/$root_disk" == "$DISK" ]]; then
      err "Refusing to operate on the currently booted disk: $DISK"
    fi
  fi

  # Check for active mounts
  if lsblk -n -o MOUNTPOINTS "$DISK" | grep -qE '\S'; then
    err "Disk '$DISK' or its partitions are mounted. Unmount them first."
  fi

  BOOT_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"

  # Rescue mode expects existing partitions
  if [[ "$MODE" == "rescue" ]]; then
    [[ ! -b "$BOOT_PART" || ! -b "$ROOT_PART" ]] && err "Rescue mode requires existing: $BOOT_PART and $ROOT_PART"
  else
    # 4. Install mode warns about existing data
    if lsblk -n "$DISK" | grep -q "part"; then
      warn "Disk '$DISK' contains partitions. ALL DATA WILL BE DESTROYED."
    fi
  fi

  # Explicit confirmation (NO --force bypass)
  local prompt
  if [[ "$MODE" == "install" ]]; then
    prompt="[!]  This will WIPE '$DISK' and install NixOS. Type 'yes' to continue: "
  else
    prompt="[!]  Proceed with '$MODE' on '$DISK'? Type 'yes' to continue: "
  fi

  read -r -p "$(echo -e "${RED}$prompt${NC}")" confirm
  [[ "$confirm" != "yes" ]] && { log "Aborted by user."; exit 0; }
}

partition_and_format() {
  step "Partitioning $DISK..."
  parted "$DISK" --script -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary 513MiB 100% || err "Partitioning failed"

  step "Formatting partitions..."
  mkfs.vfat -F32 -n "NIX-BOOT" "$BOOT_PART" || err "Boot format failed"
  mkfs.btrfs -f -L "nix-root" "$ROOT_PART" || err "Root format failed"
}

mount_system() {
  step "Creating Btrfs subvolumes..."
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@var
  umount /mnt

  step "Mounting filesystems..."
  mount -o subvol=@,noatime,compress=zstd:3 "$ROOT_PART" /mnt
  mkdir -p /mnt/{home,nix,var,boot}
  mount -o subvol=@home,noatime,compress=zstd:3 "$ROOT_PART" /mnt/home
  mount -o subvol=@nix,noatime,compress=zstd:3 "$ROOT_PART" /mnt/nix
  mount -o subvol=@var,noatime,compress=zstd:3 "$ROOT_PART" /mnt/var
  mount "$BOOT_PART" /mnt/boot
}

setup_swap() {
  step "Creating swapfile..."
  btrfs filesystem mkswapfile --size 7G /mnt/var/swapfile || err "Swapfile creation failed"
  chmod 600 /mnt/var/swapfile
  swapon /mnt/var/swapfile || warn "Swap activation failed (continuing without swap)"
}

run_install() {
  partition_and_format
  mount_system
  setup_swap

  step "Generating NixOS configuration..."
  nixos-generate-config --root /mnt || err "Config generation failed"

  step "Installing NixOS..."
  if [[ -f flake.nix ]]; then
    nixos-install --flake ".#nixos" --no-root-passwd || err "Flake installation failed"
  else
    nixos-install --no-root-passwd || err "Installation failed"
  fi
  log "[*] Installation complete. Reboot when ready."
}

run_rescue() {
  mount_system
  if [[ -f /mnt/var/swapfile ]]; then
    swapon /mnt/var/swapfile 2>/dev/null || warn "Swapfile found but failed to activate"
  fi

  log "Launching nixos-enter. Type 'exit' to return to host."
  nixos-enter || err "nixos-enter failed"
}

main() {
  check_root
  check_dependencies
  parse_args "$@"
  validate

  case "$MODE" in
    install) run_install ;;
    rescue)  run_rescue ;;
  esac
}

main "$@"
