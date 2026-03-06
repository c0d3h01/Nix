#!/usr/bin/env bash

set -euo pipefail

# -*- Color codes -*-
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# -*- Global variables -*-
declare -A CONFIG
LOG_FILE="/tmp/archinstall-$(date +%Y%m%d-%H%M%S).log"
readonly LOG_FILE

# -*- Logging functions -*-
info() {
  echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

error() {
  echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

fatal() {
  error "$@"
  error "Installation failed. Check log: $LOG_FILE"
  cleanup_on_error
  exit 1
}

# -*- Cleanup function -*-
cleanup_on_error() {
  if mountpoint -q /mnt 2>/dev/null; then
    umount -R /mnt 2>/dev/null || true
  fi
}

# -*- Trap errors -*-
trap 'fatal "Script failed at line $LINENO"' ERR

# -*- Pre-flight checks -*-
check_prerequisites() {
  info "Running pre-flight checks..."

  # Check if running as root
  if [[ $EUID -ne 0 ]]; then
    fatal "This script must be run as root"
  fi

  # Check if booted in UEFI mode
  if [[ ! -d /sys/firmware/efi/efivars ]]; then
    fatal "System must be booted in UEFI mode"
  fi

  # Check internet connectivity
  if ! ping -c 1 archlinux.org &>/dev/null; then
    fatal "No internet connection detected"
  fi

  success "Pre-flight checks passed"
}

# -*- Detect available drives -*-
detect_drives() {
  info "Detecting available drives..."
  echo -e "\n${BLUE}Available drives:${NC}"
  lsblk -dno NAME,SIZE,TYPE | grep disk | awk '{print "  /dev/"$1" ("$2")"}'
  echo ""
}

# -*- Configuration function -*-
init_config() {
  local drive=""
  local hostname=""
  local username=""
  local password=""
  local confirm_password=""
  local timezone=""
  local locale=""

  info "Arch Linux Installation Configuration"
  echo ""

  # Show available drives
  detect_drives

  # Get drive selection
  read -rp "Enter drive path (e.g., /dev/nvme0n1 or /dev/sda): " drive

  if [[ ! -b $drive ]]; then
    fatal "Drive $drive does not exist"
  fi

  # Confirm drive selection
  echo -e "\n${RED}WARNING: ALL DATA ON $drive WILL BE DESTROYED!${NC}"
  read -rp "Type 'YES' to confirm: " confirm
  if [[ $confirm != "YES" ]]; then
    fatal "Installation aborted by user"
  fi

  # Get hostname
  read -rp "Enter hostname [archlinux]: " hostname
  hostname="${hostname:-archlinux}"

  # Get username
  read -rp "Enter username [c0d3h01]: " username
  username="${username:-c0d3h01}"

  # Password confirmation
  while true; do
    read -rsp "Enter password for root and user: " password
    echo
    read -rsp "Confirm password: " confirm_password
    echo
    if [[ $password == "$confirm_password" && -n $password ]]; then
      break
    else
      error "Passwords do not match or are empty. Try again."
    fi
  done

  # Get timezone
  read -rp "Enter timezone [Asia/Kolkata]: " timezone
  timezone="${timezone:-Asia/Kolkata}"

  # Get locale
  read -rp "Enter locale [en_IN.UTF-8]: " locale
  locale="${locale:-en_IN.UTF-8}"

  # Determine partition naming scheme
  if [[ $drive =~ nvme|mmcblk ]]; then
    CONFIG[EFI_PART]="${drive}p1"
    CONFIG[ROOT_PART]="${drive}p2"
  else
    CONFIG[EFI_PART]="${drive}1"
    CONFIG[ROOT_PART]="${drive}2"
  fi

  CONFIG[DRIVE]="$drive"
  CONFIG[HOSTNAME]="$hostname"
  CONFIG[USERNAME]="$username"
  CONFIG[PASSWORD]="$password"
  CONFIG[TIMEZONE]="$timezone"
  CONFIG[LOCALE]="$locale"

  # Display configuration summary
  info "Configuration Summary:"
  echo -e "Drive:     ${CONFIG[DRIVE]}"
  echo -e "Hostname:  ${CONFIG[HOSTNAME]}"
  echo -e "Username:  ${CONFIG[USERNAME]}"
  echo -e "Timezone:  ${CONFIG[TIMEZONE]}"
  echo -e "Locale:    ${CONFIG[LOCALE]}"
  echo ""

  read -rp "Proceed with installation? (y/N): " proceed
  if [[ ! $proceed =~ ^[Yy]$ ]]; then
    fatal "Installation aborted by user"
  fi
}

# -*- Disk setup -*-
setup_disk() {
  info "Setting up disk: ${CONFIG[DRIVE]}"

  # Wipe and prepare the disk
  wipefs -af "${CONFIG[DRIVE]}"
  sgdisk --zap-all "${CONFIG[DRIVE]}"

  # Create fresh GPT
  sgdisk --clear "${CONFIG[DRIVE]}"

  # Create partitions
  sgdisk \
    --new=1:0:+1G --typecode=1:ef00 --change-name=1:"EFI" \
    --new=2:0:0 --typecode=2:8300 --change-name=2:"ROOT" \
    "${CONFIG[DRIVE]}"

  # Reload the partition table
  partprobe "${CONFIG[DRIVE]}"
  sleep 2

  # Verify partitions were created
  if [[ ! -b ${CONFIG[EFI_PART]} ]] || [[ ! -b ${CONFIG[ROOT_PART]} ]]; then
    fatal "Failed to create partitions"
  fi

  success "Disk setup completed"
}

# -*- Filesystem setup -*-
setup_filesystems() {
  info "Setting up filesystems..."

  # Format partitions
  mkfs.fat -F32 "${CONFIG[EFI_PART]}"
  mkfs.btrfs -L "ROOT" -n 16k -f "${CONFIG[ROOT_PART]}"

  # Mount root partition temporarily
  mount "${CONFIG[ROOT_PART]}" /mnt

  # Create subvolumes
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@tmp
  btrfs subvolume create /mnt/@log
  btrfs subvolume create /mnt/@cache

  # Unmount and remount with subvolumes
  umount /mnt
  mount -o "subvol=@,noatime,compress=zstd:3,ssd,space_cache=v2" "${CONFIG[ROOT_PART]}" /mnt

  # Create necessary directories
  mkdir -p /mnt/boot/efi /mnt/home /mnt/var/tmp /mnt/var/log /mnt/var/cache

  # Mount EFI and subvolumes
  mount "${CONFIG[EFI_PART]}" /mnt/boot/efi
  mount -o "subvol=@home,noatime,compress=zstd:3,ssd,space_cache=v2" "${CONFIG[ROOT_PART]}" /mnt/home
  mount -o "subvol=@tmp,noatime,compress=zstd:3,ssd,space_cache=v2" "${CONFIG[ROOT_PART]}" /mnt/var/tmp
  mount -o "subvol=@cache,nodatacow,noatime,ssd,space_cache=v2" "${CONFIG[ROOT_PART]}" /mnt/var/cache
  mount -o "subvol=@log,noatime,compress=zstd:3,ssd,space_cache=v2" "${CONFIG[ROOT_PART]}" /mnt/var/log

  success "Filesystems setup completed"
}

# -*- Base system installation -*-
install_base_system() {
  info "Installing base system..."

  info "Configuring pacman for ISO installation..."
  # Configure pacman for arch-iso
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' "/etc/pacman.conf"
  sed -i '/^# Misc options/a DisableDownloadTimeout' "/etc/pacman.conf"

  # Refresh package databases
  pacman -Syy

  info "Running reflector..."
  if ! command -v reflector &>/dev/null; then
    pacman -S --noconfirm reflector
  fi

  reflector --country India --age 6 --protocol https --sort rate --fastest 20 \
    --save /etc/pacman.d/mirrorlist

  local base_packages=(
    # -*- Core System -*-
    base           # Minimal package set to define a basic Arch Linux installation
    base-devel     # Basic tools to build Arch Linux packages
    linux-firmware # Firmware files for Linux
    linux-lts      # The LTS Linux kernel and modules

    # -*- Filesystem -*-
    btrfs-progs # Btrfs filesystem utilities

    # -*- Boot -*-
    grub       # GNU GRand Unified Bootloader
    efibootmgr # Linux user-space application to modify the EFI Boot Manager

    # -*- CPU & GPU Drivers -*-
    amd-ucode         # Microcode update image for AMD CPUs
    libva-mesa-driver # mesa with 32bit driver
    mesa              # Open-source OpenGL drivers
    vulkan-radeon     # Open-source Vulkan driver for AMD GPUs

    # -*- Network & firewall -*-
    networkmanager # Network connection manager and user applications
    firewalld      # Firewall daemon with D-Bus interface

    # -*- Multimedia & Bluetooth -*-
    bluez            # Daemons for the bluetooth protocol stack
    bluez-utils      # Development and debugging utilities for the bluetooth protocol stack
    pipewire         # Low-latency audio/video router and processor
    pipewire-pulse   # Low-latency audio/video router and processor - PulseAudio replacement
    pipewire-alsa    # Low-latency audio/video router and processor - ALSA configuration
    pipewire-jack    # Low-latency audio/video router and processor - JACK replacement
    wireplumber      # Session / policy manager implementation for PipeWire
    gstreamer        # Multimedia graph framework - core
    gst-libav        # Multimedia graph framework - libav plugin
    gst-plugins-base # Multimedia graph framework - base plugins
    gst-plugins-good # Multimedia graph framework - good plugins
    gst-plugins-bad  # Multimedia graph framework - bad plugins
    gst-plugins-ugly # Multimedia graph framework - ugly plugins

    # -*- Desktop environment [ Gnome ] -*-
    nautilus                 # Default file manager for GNOME
    sushi                    # A quick previewer for Nautilus
    totem                    # Movie player for the GNOME desktop based on GStreamer
    loupe                    # A simple image viewer for GNOME
    evince                   # Document viewer (PDF, PostScript, XPS, djvu, dvi, tiff, cbr, cbz, cb7, cbt)
    file-roller              # Create and modify archives
    vlc                      # Free and open source cross-platform multimedia player and framework
    gnome-notes              # Write out notes, every detail matters
    gdm                      # Display manager and login screen
    gnome-settings-daemon    # GNOME Settings Daemon
    gnome-browser-connector  # Native browser connector for integration with extensions.gnome.org
    gnome-backgrounds        # Background images and data for GNOME
    gnome-session            # The GNOME Session Handler
    gnome-calculator         # GNOME Scientific calculator
    gnome-clocks             # gnome-clocks
    gnome-control-center     # GNOME's main interface to configure various aspects
    gnome-disk-utility       # Disk Management Utility for GNOME
    gnome-calendar           # Calendar application
    gnome-keyring            # Stores passwords and encryption keys
    gnome-nettool            # Graphical interface for various networking tools
    gnome-power-manager      # System power information and statistics
    gnome-screenshot         # Take pictures of your screen
    gnome-shell              # Next generation desktop shell
    gnome-themes-extra       # Extra Themes for GNOME Applications
    gnome-tweaks             # Graphical interface for advanced GNOME 3 settings (Tweak Tool)
    gnome-logs               # A log viewer for the systemd journal
    gnome-firmware           # Manage firmware on devices supported by fwupd
    snapshot                 # Take pictures and videos
    gvfs                     # VFS implementation for GIO
    gvfs-afc                 # VFS implementation for GIO - AFC backend (Apple mobile devices)
    gvfs-gphoto2             # VFS implementation for GIO - gphoto2 backend (PTP camera, MTP media player)
    gvfs-mtp                 # VFS implementation for GIO - MTP backend (Android, media player)
    gvfs-nfs                 # VFS implementation for GIO - NFS backend
    gvfs-smb                 # VFS implementation for GIO - SMB/CIFS backend (Windows file sharing)
    xdg-desktop-portal-gnome # Backend implementation for xdg-desktop-portal for the GNOME desktop environment
    xdg-user-dirs-gtk        # Creates user dirs and asks to relocalize them

    # -*- Fonts -*-
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-fira-code
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd

    # -*- Git Clients -*-
    git
    git-lfs
    git-delta
    git-crypt
    diffutils
    lazygit

    # -*- Essential System Utilities -*-
    wezterm
    zram-generator
    reflector
    pacutils
    fastfetch
    htop
    wget
    curl
    sshpass
    openssh
    inxi
    cups
    snapper
    snap-pac
    grub-btrfs
    xclip
    vim
    tmux
    docker
    docker-compose
    docker-buildx
    lazydocker

    # -*- User Utilities -*-
    chromium
    qbittorrent
  )

  info "Installing ${#base_packages[@]} packages..."
  for pkg in "${base_packages[@]}"; do
    info "Installing: $pkg"
    pacstrap -K /mnt --needed "$pkg" || error "Failed to install $pkg (continuing...)"
  done

  success "Base system installation completed"
}

# -*- System configuration -*-
configure_system() {
  info "Configuring system..."

  # Generate fstab
  genfstab -U /mnt >>/mnt/etc/fstab

  # Chroot and configure
  arch-chroot /mnt /bin/bash <<EOF
set -e

# Set timezone and synchronize hardware clock
ln -sf /usr/share/zoneinfo/${CONFIG[TIMEZONE]} /etc/localtime
hwclock --systohc

# Configure system locale
echo "${CONFIG[LOCALE]} UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=${CONFIG[LOCALE]}" > /etc/locale.conf

# Set keyboard layout for virtual console
echo "KEYMAP=us" > /etc/vconsole.conf

# Set system hostname
echo "${CONFIG[HOSTNAME]}" > /etc/hostname

# Configure hosts file
cat > /etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${CONFIG[HOSTNAME]}.localdomain ${CONFIG[HOSTNAME]}
HOSTS

# Set root password
echo "root:${CONFIG[PASSWORD]}" | chpasswd

# Create new user account
useradd -m -G wheel,video,audio,sys,rfkill,storage,lp -s /bin/bash "${CONFIG[USERNAME]}"

# Set user password
echo "${CONFIG[USERNAME]}:${CONFIG[PASSWORD]}" | chpasswd

# Enable sudo access for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Install GRUB bootloader for UEFI systems
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate GRUB configuration file
grub-mkconfig -o /boot/grub/grub.cfg

# Regenerate initramfs for all kernels
mkinitcpio -P
EOF

  success "System configuration completed"
}

# -*- Custom configuration -*-
custom_configuration() {
  info "Applying custom configuration..."

  arch-chroot /mnt /bin/bash <<EOF
set -e

# Create zram configuration
cat > /etc/systemd/zram-generator.conf <<ZRAM
[zram0]
compression-algorithm = zstd
zram-size = ram
swap-priority = 100
fs-type = swap
ZRAM

# Configure pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i '/^# Misc options/a DisableDownloadTimeout\nILoveCandy' /etc/pacman.conf
sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf

# Disable PowerSaving over NetworkManager
if command -v NetworkManager >/dev/null 2>&1; then
	mkdir -p "/etc/NetworkManager/conf.d/wifi-powersave.conf"
	printf "[connection]\nwifi.powersave=%s\n" "2" >"/etc/NetworkManager/conf.d/wifi-powersave.conf
fi

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer
systemctl enable gdm
systemctl enable lm_sensors
systemctl enable avahi-daemon
systemctl enable docker
systemctl enable sshd
systemctl enable cups.socket
systemctl enable systemd-timesyncd
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
EOF

  success "Custom configuration completed"
}

# -*- Main function -*-
main() {
  info "Starting Arch Linux installation script..."
  info "Log file: $LOG_FILE"

  # Resize fonts while installing
  setfont ter-132n 2>/dev/null || true

  # Run checks
  check_prerequisites

  # Get configuration
  init_config

  # Main installation steps
  setup_disk
  setup_filesystems
  install_base_system
  configure_system
  custom_configuration

  success "Installation complete!"
  info "Log saved to: $LOG_FILE"

  read -rp "Unmount filesystems now? (y/n): " UNMOUNT
  if [[ $UNMOUNT =~ ^[Yy]$ ]]; then
    umount -R /mnt
    success "Ready to reboot!"
    read -rp "Reboot now? (y/n): " REBOOT
    if [[ $REBOOT =~ ^[Yy]$ ]]; then
      reboot
    fi
  else
    info "Entering chroot for manual configuration..."
    arch-chroot /mnt
  fi
}

# Execute main function
main "$@"
