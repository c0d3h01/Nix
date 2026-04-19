#!/usr/bin/env bash
# =============================================================================
# nixos-rescue.sh — NixOS Partition Setup & Chroot Rescue Tool
# =============================================================================
#
# DESCRIPTION:
#   Provides two primary workflows for managing a NixOS installation:
#
#   1. PARTITION  — Wipes a target disk and creates a fresh GPT layout matching
#                   the standard NixOS btrfs configuration:
#                     nvme0n1p1  swap   4G    label: nix-swap
#                     nvme0n1p2  vfat   1G    label: nix-boot  (EFI System)
#                     nvme0n1p3  btrfs  rest  label: nix-root
#                   Creates btrfs subvolumes: @  @home  @nix
#
#   2. RESCUE     — Mounts all labeled partitions from an existing installation
#                   into /mnt and drops into a fully functional chroot with
#                   /proc /sys /dev /run properly bound. Ready for
#                   nixos-rebuild, passwd, or any system repair.
#
# USAGE:
#   nixos-rescue.sh <command> [options]
#
# COMMANDS:
#   partition   <disk>          Wipe <disk> and create the full partition layout.
#   format      <disk>          Format already-partitioned disk (skips sgdisk).
#   mount-parts                 Mount all labeled partitions to /mnt.
#   chroot                      Bind /proc /sys /dev /run, then chroot to /mnt.
#   rescue                      mount-parts + chroot in a single step.
#   umount-all                  Cleanly unmount everything under /mnt.
#   status                      Show current mount state and disk label map.
#
# OPTIONS:
#   -h, --help                  Show this help message and exit.
#   -v, --verbose               Enable xtrace (set -x) for debugging.
#   -n, --dry-run               Print commands without executing them.
#   --target  <path>            Chroot target directory. Default: /mnt
#   --swap-size  <size>         Swap partition size.  Default: 4G
#   --boot-size  <size>         Boot partition size.  Default: 1G
#
# EXAMPLES:
#   # Fresh install on /dev/nvme0n1
#   sudo ./nixos-rescue.sh partition /dev/nvme0n1
#
#   # Rescue a broken system (labels already exist on disk)
#   sudo ./nixos-rescue.sh rescue
#
#   # Rescue into a non-standard mountpoint
#   sudo ./nixos-rescue.sh rescue --target /mnt/recovery
#
#   # Dry-run to see what partition would do
#   sudo ./nixos-rescue.sh partition /dev/nvme0n1 --dry-run
#
# PARTITION LABELS (hardcoded to match NixOS config):
#   nix-boot    EFI vfat partition
#   nix-root    btrfs root partition
#   nix-swap    swap partition
#
# BTRFS SUBVOLUMES:
#   @           mounted at  /
#   @home       mounted at  /home
#   @nix        mounted at  /nix
#
# REQUIREMENTS:
#   sgdisk, mkfs.vfat, mkfs.btrfs, mkswap, mount, arch-chroot (or chroot)
#   Must be run as root from a NixOS or Arch Linux live environment.
#
# AUTHOR:  c0d3h01
# VERSION: 1.0.0
# =============================================================================

set -euo pipefail

# =============================================================================
# CONSTANTS — Labels must match your NixOS flake configuration exactly.
# =============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"

# Partition labels — must match what your NixOS modules reference via
# /dev/disk/by-label/. Changing these requires updating your NixOS config too.
readonly LABEL_BOOT="nix-boot"
readonly LABEL_ROOT="nix-root"
readonly LABEL_SWAP="nix-swap"

# Btrfs subvolume names — must match disko or fileSystems in your flake.
readonly SUBVOL_ROOT="@"
readonly SUBVOL_HOME="@home"
readonly SUBVOL_NIX="@nix"

# Btrfs mount options — mirrors what is declared in your NixOS fileSystems.
readonly BTRFS_OPTS_ROOT="noatime,compress=zstd:1"
readonly BTRFS_OPTS_HOME="noatime,compress=zstd:3"
readonly BTRFS_OPTS_NIX="noatime,compress=zstd:3"

# =============================================================================
# DEFAULTS — Overridable via CLI flags.
# =============================================================================

TARGET="/mnt"
SWAP_SIZE="4G"
BOOT_SIZE="1G"
DRY_RUN=false
VERBOSE=false

# =============================================================================
# COLOUR OUTPUT — Degrades gracefully when stdout is not a terminal.
# =============================================================================

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' RESET=''
fi

# =============================================================================
# LOGGING HELPERS
# =============================================================================

# log::info — Informational message. Always printed.
log::info() {
    echo -e "${GREEN}[INFO]${RESET}  $*"
}

# log::warn — Warning. Continues execution.
log::warn() {
    echo -e "${YELLOW}[WARN]${RESET}  $*" >&2
}

# log::error — Non-fatal error message to stderr.
log::error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

# log::fatal — Prints error and exits with code 1.
log::fatal() {
    echo -e "${RED}[FATAL]${RESET} $*" >&2
    exit 1
}

# log::step — Visually distinct section header for multi-step operations.
log::step() {
    echo -e "\n${BOLD}${CYAN}==> $*${RESET}"
}

# log::cmd — Prints the command about to be run. In dry-run mode, stops there.
log::cmd() {
    echo -e "${BLUE}[RUN]${RESET}   $*"
    if $DRY_RUN; then
        return 0
    fi
    eval "$*"
}

# =============================================================================
# PRECONDITION GUARDS
# =============================================================================

# guard::root — Abort if not running as root. All disk operations require it.
guard::root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log::fatal "This script must be run as root. Use: sudo $SCRIPT_NAME $*"
    fi
}

# guard::tool — Abort if a required binary is not found in PATH.
guard::tool() {
    local tool="$1"
    if ! command -v "$tool" &>/dev/null; then
        log::fatal "Required tool not found: '${tool}'. Install it in your live environment."
    fi
}

# guard::disk — Verify the given path is a block device before touching it.
guard::disk() {
    local disk="$1"
    if [[ ! -b "$disk" ]]; then
        log::fatal "Not a block device: '${disk}'. Check the path and try again."
    fi
}

# guard::confirm — Interactive confirmation gate for destructive operations.
# Skipped automatically in dry-run mode.
guard::confirm() {
    local prompt="$1"
    if $DRY_RUN; then
        log::warn "Dry-run: skipping confirmation for: ${prompt}"
        return 0
    fi
    echo -e "${RED}${BOLD}[!] ${prompt}${RESET}"
    echo -n "    Type 'yes' to continue, anything else to abort: "
    local answer
    read -r answer
    if [[ "$answer" != "yes" ]]; then
        log::info "Aborted by user."
        exit 0
    fi
}

# =============================================================================
# DISK LABEL RESOLUTION
# Resolves partition paths by label to avoid hardcoded /dev/nvme0n1pN paths,
# which change across disks or after partition table modifications.
# =============================================================================

# disk::by_label — Resolve /dev/disk/by-label/<label> to its real device path.
# Returns the resolved path or exits fatally if the label does not exist.
disk::by_label() {
    local label="$1"
    local path="/dev/disk/by-label/${label}"
    if [[ ! -e "$path" ]]; then
        log::fatal "Disk label '${label}' not found. Is the partition formatted and the label set correctly?"
    fi
    readlink -f "$path"
}

# =============================================================================
# COMMAND: partition
# Wipes the target disk and creates the GPT partition layout from scratch.
# Partition order: swap → boot (ESP) → root
# This order matches the user's existing working partition table.
# =============================================================================

cmd::partition() {
    local disk="$1"

    guard::root
    guard::tool sgdisk
    guard::tool mkfs.vfat
    guard::tool mkfs.btrfs
    guard::tool mkswap
    guard::disk "$disk"

    guard::confirm "THIS WILL PERMANENTLY DESTROY ALL DATA ON ${disk}."

    log::step "Partitioning ${disk}"

    # Wipe all existing partition table signatures cleanly before writing a
    # new GPT. This prevents leftover LVM, RAID, or filesystem metadata from
    # confusing the kernel or udev after repartitioning.
    log::info "Zapping existing partition table on ${disk}..."
    log::cmd "sgdisk --zap-all '${disk}'"
    log::cmd "wipefs --all '${disk}'"

    log::info "Creating GPT partition table..."

    # Partition 1 — Linux swap (type 8200)
    # Size is configurable via --swap-size. Label is set here for sgdisk;
    # the actual filesystem label applied by mkswap is set in cmd::format.
    log::cmd "sgdisk --new=1:0:+${SWAP_SIZE} --typecode=1:8200 --change-name=1:'${LABEL_SWAP}' '${disk}'"

    # Partition 2 — EFI System Partition (type EF00)
    # Must be vfat. GRUB and systemd-boot both require this partition to be
    # discoverable via its EFI type GUID (EF00). 1G is generous but avoids
    # running out of space after many NixOS generations accumulate kernels.
    log::cmd "sgdisk --new=2:0:+${BOOT_SIZE} --typecode=2:EF00 --change-name=2:'${LABEL_BOOT}' '${disk}'"

    # Partition 3 — Linux filesystem / btrfs root (type 8300)
    # Takes all remaining space on the disk.
    log::cmd "sgdisk --new=3:0:0 --typecode=3:8300 --change-name=3:'${LABEL_ROOT}' '${disk}'"

    # Inform the kernel of the new partition table without requiring a reboot.
    log::info "Reloading partition table..."
    log::cmd "partprobe '${disk}'"
    log::cmd "sleep 2"

    log::info "Partition layout created. Proceeding to format..."
    cmd::format "$disk"
}

# =============================================================================
# COMMAND: format
# Applies filesystems to the three partitions identified by their sgdisk
# partition number on the given disk. Separated from cmd::partition so it
# can be re-run independently if formatting fails mid-way.
# =============================================================================

cmd::format() {
    local disk="$1"

    guard::root
    guard::disk "$disk"

    # Derive partition device paths. Handles both nvme (p1/p2/p3) and
    # sata/virtio (1/2/3) naming conventions automatically.
    local part_prefix="${disk}"
    if [[ "$disk" == *"nvme"* ]] || [[ "$disk" == *"mmcblk"* ]]; then
        part_prefix="${disk}p"
    fi

    local part_swap="${part_prefix}1"
    local part_boot="${part_prefix}2"
    local part_root="${part_prefix}3"

    log::step "Formatting partitions"

    # Format swap — the filesystem label here is what NixOS references via
    # /dev/disk/by-label/nix-swap in fileSystems or disko config.
    log::info "Formatting swap: ${part_swap}"
    log::cmd "mkswap --label '${LABEL_SWAP}' '${part_swap}'"
    log::cmd "swapon '${part_swap}'"

    # Format EFI — FAT32 is the only format the UEFI spec mandates support
    # for. The -F 32 flag forces FAT32 regardless of partition size.
    # -n sets the volume label, matching LABEL_BOOT for by-label resolution.
    log::info "Formatting EFI boot: ${part_boot}"
    log::cmd "mkfs.vfat -F 32 -n '${LABEL_BOOT}' '${part_boot}'"

    # Format btrfs root — -f forces overwrite of any existing filesystem.
    # -L sets the filesystem label. --checksum xxhash uses a faster checksum
    # algorithm than the default crc32c on modern kernels (5.5+).
    log::info "Formatting btrfs root: ${part_root}"
    log::cmd "mkfs.btrfs -f -L '${LABEL_ROOT}' '${part_root}'"

    log::step "Creating btrfs subvolumes"
    cmd::create_subvolumes "$part_root"
}

# =============================================================================
# INTERNAL: create_subvolumes
# Mounts the raw btrfs partition (no subvol), creates the three required
# subvolumes, then unmounts. The subvolumes are later mounted individually
# by cmd::mount_parts with their specific options.
# =============================================================================

cmd::create_subvolumes() {
    local part_root="$1"
    local tmp_mount
    tmp_mount="$(mktemp -d)"

    log::info "Temporarily mounting ${part_root} to create subvolumes..."
    log::cmd "mount -t btrfs '${part_root}' '${tmp_mount}'"

    # Three subvolumes matching the NixOS fileSystems declarations:
    #   @       → /
    #   @home   → /home   (kept separate so / can be wiped without losing data)
    #   @nix    → /nix    (kept separate for efficient snapshotting of store)
    for subvol in "$SUBVOL_ROOT" "$SUBVOL_HOME" "$SUBVOL_NIX"; do
        log::info "Creating subvolume: ${subvol}"
        log::cmd "btrfs subvolume create '${tmp_mount}/${subvol}'"
    done

    log::cmd "umount '${tmp_mount}'"
    log::cmd "rmdir '${tmp_mount}'"

    log::info "Subvolumes created successfully."
    log::info "You can now run: nixos-install --flake .#c0d3h01"
}

# =============================================================================
# COMMAND: mount-parts
# Resolves all three labeled partitions and mounts them into TARGET (/mnt).
# Used as the first step of rescue and also useful standalone during installs.
# =============================================================================

cmd::mount_parts() {
    guard::root
    guard::tool mount

    log::step "Resolving partitions by label"

    local dev_root dev_boot dev_swap
    dev_root="$(disk::by_label "$LABEL_ROOT")"
    dev_boot="$(disk::by_label "$LABEL_BOOT")"
    dev_swap="$(disk::by_label "$LABEL_SWAP")"

    log::info "  nix-root → ${dev_root}"
    log::info "  nix-boot → ${dev_boot}"
    log::info "  nix-swap → ${dev_swap}"

    log::step "Mounting btrfs subvolumes into ${TARGET}"

    # Mount the @ subvolume as the root of the chroot environment.
    # noatime prevents inode access-time updates on every file read, which
    # reduces write amplification significantly on NVMe and btrfs CoW layouts.
    log::info "Mounting @ → ${TARGET}"
    log::cmd "mount -t btrfs -o subvol=${SUBVOL_ROOT},${BTRFS_OPTS_ROOT} '${dev_root}' '${TARGET}'"

    # Create mountpoints inside the newly mounted root before mounting
    # the remaining subvolumes. These directories must exist on the btrfs
    # @ subvolume to avoid the mount silently overlaying a wrong path.
    log::cmd "mkdir -p '${TARGET}/home'"
    log::cmd "mkdir -p '${TARGET}/nix'"
    log::cmd "mkdir -p '${TARGET}/boot'"

    log::info "Mounting @home → ${TARGET}/home"
    log::cmd "mount -t btrfs -o subvol=${SUBVOL_HOME},${BTRFS_OPTS_HOME} '${dev_root}' '${TARGET}/home'"

    log::info "Mounting @nix → ${TARGET}/nix"
    log::cmd "mount -t btrfs -o subvol=${SUBVOL_NIX},${BTRFS_OPTS_NIX} '${dev_root}' '${TARGET}/nix'"

    log::info "Mounting EFI boot → ${TARGET}/boot"
    log::cmd "mount '${dev_boot}' '${TARGET}/boot'"

    # Enable swap so the chroot environment has the same memory headroom as
    # the installed system. Particularly important for nixos-rebuild inside chroot.
    log::info "Enabling swap: ${dev_swap}"
    log::cmd "swapon '${dev_swap}'" || log::warn "swapon failed — swap may already be active."

    log::info "All partitions mounted under ${TARGET}."
}

# =============================================================================
# COMMAND: chroot
# Bind-mounts the four kernel pseudo-filesystems required for a functional
# chroot, then drops into the environment. Uses arch-chroot if available
# (handles bind mounts automatically), falls back to plain chroot.
# =============================================================================

cmd::chroot() {
    guard::root

    log::step "Binding kernel filesystems into ${TARGET}"

    # /proc — required by virtually every tool: ps, top, nixos-rebuild, systemd.
    log::cmd "mount --bind /proc '${TARGET}/proc'"

    # /sys — required for udev, hardware detection, kernel parameter reads.
    log::cmd "mount --bind /sys '${TARGET}/sys'"

    # /dev — required to access block devices inside the chroot for installs.
    log::cmd "mount --bind /dev '${TARGET}/dev'"

    # /dev/pts — required for pseudo-terminals (ssh, tmux, interactive shells).
    log::cmd "mount --bind /dev/pts '${TARGET}/dev/pts'"

    # /run — required by systemd, dbus, and NixOS activation scripts which
    # write sockets and PID files here during boot sequence emulation.
    log::cmd "mount --bind /run '${TARGET}/run'"

    # Copy host resolv.conf so DNS works inside the chroot. This is needed
    # for nixos-rebuild to fetch substitutes and update flake inputs.
    if [[ -f /etc/resolv.conf ]]; then
        log::info "Copying /etc/resolv.conf for DNS resolution inside chroot..."
        log::cmd "cp /etc/resolv.conf '${TARGET}/etc/resolv.conf'"
    fi

    log::step "Entering chroot at ${TARGET}"
    log::info "To rebuild: nixos-rebuild switch --flake /path/to/your/flake#c0d3h01"
    log::info "To exit:    type 'exit' or press Ctrl-D"
    echo ""

    # Prefer arch-chroot when available — it manages bind mounts automatically,
    # handles /etc/mtab linking, and sets up a clean login shell environment.
    if command -v arch-chroot &>/dev/null; then
        log::info "Using arch-chroot..."
        arch-chroot "$TARGET" /bin/bash
    else
        # Plain chroot with explicit PATH matching a typical NixOS login shell.
        log::info "arch-chroot not found, using plain chroot..."
        chroot "$TARGET" /usr/bin/env \
            PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/bin:/usr/bin" \
            HOME="/root" \
            TERM="$TERM" \
            /bin/bash --login
    fi
}

# =============================================================================
# COMMAND: rescue
# Combined mount-parts + chroot. The primary workflow for fixing a broken system.
# After exiting the chroot, all mounts are cleaned up automatically.
# =============================================================================

cmd::rescue() {
    guard::root

    log::step "Starting rescue mode"
    log::info "Target: ${TARGET}"

    cmd::mount_parts
    cmd::chroot

    # Reached here after the user exits the chroot shell.
    log::step "Exited chroot — cleaning up mounts"
    cmd::umount_all
}

# =============================================================================
# COMMAND: umount-all
# Unmounts all bind mounts and partition mounts under TARGET in reverse order.
# Uses --lazy (-l) as a fallback to handle busy mounts gracefully.
# =============================================================================

cmd::umount_all() {
    guard::root

    log::step "Unmounting all filesystems under ${TARGET}"

    # Unmount in reverse dependency order. Kernel pseudo-filesystems first,
    # then subvolumes, then the root last. Reversing mount order prevents
    # "target is busy" errors from nested mounts blocking the parent.
    local mounts=(
        "${TARGET}/dev/pts"
        "${TARGET}/dev"
        "${TARGET}/proc"
        "${TARGET}/sys"
        "${TARGET}/run"
        "${TARGET}/boot"
        "${TARGET}/home"
        "${TARGET}/nix"
        "${TARGET}"
    )

    for mountpoint in "${mounts[@]}"; do
        if mountpoint -q "$mountpoint" 2>/dev/null; then
            log::info "Unmounting: ${mountpoint}"
            umount "$mountpoint" 2>/dev/null || umount --lazy "$mountpoint"
        else
            log::info "Skipping (not mounted): ${mountpoint}"
        fi
    done

    # Disable swap partition if it was enabled by this session.
    local dev_swap
    if dev_swap="$(disk::by_label "$LABEL_SWAP" 2>/dev/null)"; then
        if swapon --show | grep -q "$dev_swap"; then
            log::info "Disabling swap: ${dev_swap}"
            swapoff "$dev_swap" || log::warn "swapoff failed — may require manual intervention."
        fi
    fi

    log::info "Unmount complete."
}

# =============================================================================
# COMMAND: status
# Prints a human-readable overview of what is currently mounted under TARGET
# and which disk labels are visible on this machine.
# =============================================================================

cmd::status() {
    log::step "Disk labels visible on this system"
    if [[ -d /dev/disk/by-label ]]; then
        ls -la /dev/disk/by-label/ | grep -E "${LABEL_BOOT}|${LABEL_ROOT}|${LABEL_SWAP}" \
            || log::warn "None of the expected NixOS labels found. Wrong live environment or disk?"
    else
        log::warn "/dev/disk/by-label not available."
    fi

    log::step "Active mounts under ${TARGET}"
    if mount | grep -q "$TARGET"; then
        mount | grep "$TARGET"
    else
        log::info "Nothing mounted under ${TARGET}."
    fi

    log::step "Active swap"
    swapon --show || log::info "No active swap."
}

# =============================================================================
# USAGE / HELP
# =============================================================================

usage() {
    cat <<EOF
${BOLD}${SCRIPT_NAME}${RESET} v${SCRIPT_VERSION} — NixOS Partition & Rescue Tool

${BOLD}USAGE${RESET}
  $SCRIPT_NAME <command> [options]

${BOLD}COMMANDS${RESET}
  partition  <disk>    Wipe <disk>, partition, format, create btrfs subvolumes.
  format     <disk>    Format already-partitioned <disk> (skip sgdisk).
  mount-parts          Mount labeled partitions into --target (default: /mnt).
  chroot               Bind kernel fs and chroot into --target.
  rescue               mount-parts + chroot. Unmounts on exit. (Most common)
  umount-all           Unmount everything under --target cleanly.
  status               Show label resolution and current mount state.

${BOLD}OPTIONS${RESET}
  -h, --help           Show this help and exit.
  -v, --verbose        Enable bash xtrace (set -x).
  -n, --dry-run        Print commands, do not execute.
  --target  <path>     Chroot/mount root. Default: /mnt
  --swap-size <size>   Swap partition size (sgdisk format). Default: 4G
  --boot-size <size>   Boot partition size (sgdisk format). Default: 1G

${BOLD}EXAMPLES${RESET}
  # Full fresh install setup
  sudo $SCRIPT_NAME partition /dev/nvme0n1

  # Rescue a broken boot
  sudo $SCRIPT_NAME rescue

  # Rescue into custom mountpoint
  sudo $SCRIPT_NAME rescue --target /mnt/nixos

  # See what is mounted now
  sudo $SCRIPT_NAME status

  # Preview what partition would do without touching the disk
  sudo $SCRIPT_NAME partition /dev/nvme0n1 --dry-run

${BOLD}PARTITION LABELS${RESET}
  ${LABEL_SWAP}     Linux swap
  ${LABEL_BOOT}     EFI System (vfat/FAT32)
  ${LABEL_ROOT}     btrfs root with subvolumes @, @home, @nix

EOF
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

parse_args() {
    # Extract the subcommand first (first positional argument).
    local command="${1:-}"

    # Shift past the command so remaining args are just options/operands.
    [[ -n "$command" ]] && shift

    # Parse remaining flags. Unknown flags are rejected to prevent silent
    # misconfiguration rather than falling through to unexpected behaviour.
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                set -x
                ;;
            -n|--dry-run)
                DRY_RUN=true
                log::warn "Dry-run mode active — no disk changes will be made."
                ;;
            --target)
                TARGET="${2:?--target requires a path argument}"
                shift
                ;;
            --swap-size)
                SWAP_SIZE="${2:?--swap-size requires a size argument (e.g. 4G)}"
                shift
                ;;
            --boot-size)
                BOOT_SIZE="${2:?--boot-size requires a size argument (e.g. 1G)}"
                shift
                ;;
            -*)
                log::fatal "Unknown option: '${1}'. Run '$SCRIPT_NAME --help' for usage."
                ;;
            *)
                # Remaining positional argument (e.g. disk path for partition/format).
                POSITIONAL_ARG="$1"
                ;;
        esac
        shift
    done

    # Dispatch to the appropriate command handler.
    case "$command" in
        partition)
            local disk="${POSITIONAL_ARG:?'partition' requires a disk argument (e.g. /dev/nvme0n1)}"
            cmd::partition "$disk"
            ;;
        format)
            local disk="${POSITIONAL_ARG:?'format' requires a disk argument (e.g. /dev/nvme0n1)}"
            cmd::format "$disk"
            ;;
        mount-parts)
            cmd::mount_parts
            ;;
        chroot)
            cmd::chroot
            ;;
        rescue)
            cmd::rescue
            ;;
        umount-all)
            cmd::umount_all
            ;;
        status)
            cmd::status
            ;;
        ""|--help|-h)
            usage
            exit 0
            ;;
        *)
            log::fatal "Unknown command: '${command}'. Run '$SCRIPT_NAME --help' for usage."
            ;;
    esac
}

# =============================================================================
# ENTRY POINT
# =============================================================================

POSITIONAL_ARG=""
parse_args "$@"
