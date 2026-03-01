#!/usr/bin/env bash
# 1. Mount the root BTRFS subvolume first
sudo mount -t btrfs -o subvol=/@ /dev/nvme0n1p3 /mnt

# 2. Create the necessary mount points inside the new root
sudo mkdir -p /mnt/{home,nix,var/tmp,var/log,boot}

# 3. Mount the remaining BTRFS subvolumes
sudo mount -t btrfs -o subvol=/@home /dev/nvme0n1p3 /mnt/home
sudo mount -t btrfs -o subvol=/@nix /dev/nvme0n1p3 /mnt/nix
sudo mount -t btrfs -o subvol=/@tmp /dev/nvme0n1p3 /mnt/var/tmp
sudo mount -t btrfs -o subvol=/@log /dev/nvme0n1p3 /mnt/var/log

# 4. Mount the EFI Boot partition
sudo mount /dev/nvme0n1p1 /mnt/boot

# 5. Enable swap (Optional, but good practice)
sudo swapon /dev/nvme0n1p2

# 6. Enter the NixOS environment
sudo nixos-enter --root /mnt
