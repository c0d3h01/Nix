<div align="center">

# ❄️ nix-dotfiles

**Declarative NixOS workstation — reproducible, hardened, minimal.**

[![Validate](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/flake-validator.yml/badge.svg)](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/flake-validator.yml)
[![Format](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/auto-fmt.yml/badge.svg)](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/auto-fmt.yml)
[![Update flake inputs](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/flake-update.yml/badge.svg)](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/flake-update.yml)
[![Update submodules](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/submodules.yml/badge.svg)](https://github.com/c0d3h01/nix-dotfiles/actions/workflows/submodules.yml)
[![License](https://img.shields.io/github/license/c0d3h01/nix-dotfiles?color=blue)](LICENSE)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

</div>

---

## Overview

A single-flake NixOS configuration for a GNOME-based developer laptop.
Everything — system, home environment, secrets, disk layout — is declared in Nix
and version-controlled. One command rebuilds the entire machine identically.

**Design principles:**

| | |
|---|---|
| 🔒 **Hardened** | Firewall enabled, SSH brute-force protection, sysctl hardening, DNS-over-TLS |
| ⚡ **Performance** | Zen kernel, zram swap, BBR congestion, BFQ/mq-deadline I/O scheduling |
| 📦 **Reproducible** | Flake-locked inputs, Disko partitioning, sops-nix secrets |
| 🧩 **Modular** | Each concern in its own file — swap bootloaders, DEs, or services in one line |

---

## Repository Structure

<details>
<summary><b>Click to expand</b></summary>

```
.
├── flake.nix                   # Entrypoint — inputs & outputs
├── flake/                      # Flake parts
│   ├── hosts.nix               #   NixOS, Home Manager, ISO builders
│   ├── dev-shell.nix           #   Development shell (linters, tools)
│   ├── formatter.nix           #   treefmt (alejandra, deadnix, statix)
│   └── overlays.nix            #   Custom nixpkgs overlays
│
├── hosts/                      # Per-machine definitions
│   ├── default.nix             #   Host registry (system, user, DE, bootloader)
│   └── laptop/                 #   Laptop-specific config + Disko layout
│
├── modules/
│   ├── nixos/                  # System-level NixOS modules
│   │   ├── boot/               #   GRUB / Limine / systemd-boot
│   │   ├── desktop/            #   GNOME / Plasma / XFCE
│   │   ├── hardware/           #   Base platform, GPU, filesystems, udev, zram
│   │   ├── kernel/             #   Zen kernel, sysctl tuning & hardening
│   │   ├── networking/         #   Firewall, NetworkManager, OpenSSH, DNS
│   │   ├── nix/                #   Daemon config, store optimization, flakes
│   │   ├── security/           #   GPG agent, sops-nix secrets
│   │   ├── services/           #   Docker, libvirt, Ollama, Wireshark
│   │   └── system/             #   Audio, fonts, packages, user, scheduler
│   │
│   └── home/                   # Home Manager modules
│       ├── core/               #   XDG, session variables, sops secrets
│       ├── cli/                #   bat, fzf, ripgrep, zoxide, dircolors
│       ├── dev/                #   Neovim, Git, Lazygit, direnv
│       ├── terminal/           #   WezTerm, tmux
│       └── media/              #   Spicetify, yt-dlp, OpenClaw
│
├── secrets/                    # Age-encrypted secrets (sops-nix)
├── Makefile                    # Convenience commands
└── .github/workflows/          # CI — validate, format, update, merge
```

</details>

## Hosts

| Host | Arch | DE | Bootloader | Kernel | Features |
|---|---|---|---|---|---|
| `laptop` | `x86_64-linux` | GNOME | systemd-boot | Zen | Workstation, AMD GPU, zram, Disko NVMe |

---

## Quick Start

### Prerequisites

A running NixOS install with flakes enabled, or any system with the Nix package manager.

### Rebuild

```bash
# Full system rebuild
make rebuild laptop

# Home Manager only
make home laptop

# Build installer ISO
make iso laptop
```

### All Make targets

```bash
make help
```

```
Usage: make <target> [HOST=<host>]

  rebuild      NixOS rebuild switch
  home         Home Manager switch
  iso          Build installer ISO
  check        Flake check (all systems)
  fmt          Format all Nix files
  clean        GC + optimise Nix store
```

---

## Clean Install

Wipe, partition, and install onto a new machine via [Disko](https://github.com/nix-community/disko):

```bash
# 1. Partition & format (DESTRUCTIVE — wipes the target disk)
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks \
  --flake github:c0d3h01/nix-dotfiles#laptop

# 2. Install NixOS
sudo nixos-install --flake github:c0d3h01/nix-dotfiles#laptop --no-root-passwd

# 3. Reboot
sudo reboot
```

---

## What's Configured

### System Hardening

- **Kernel** — ASLR max, dmesg restricted, perf_event_paranoid=3, protected symlinks/hardlinks/FIFOs
- **Network** — SYN flood protection, ICMP/source-route/redirect blocking, Martian logging, strict rp_filter
- **Firewall** — nftables enabled with explicit allow-list, reverse-path filtering (loose for VMs)
- **SSH** — Key-only auth, post-quantum KEX (sntrup761, mlkem768), rate-limited connections
- **DNS** — DNS-over-TLS (opportunistic) via systemd-resolved, DNSSEC allow-downgrade

### Performance Tuning

- **Kernel** — `linuxPackages_zen` with BBR congestion control, `fq` qdisc
- **Memory** — zram swap (LZ4, swappiness=180), tuned dirty page writeback for 6 GB RAM
- **I/O** — BFQ for HDDs, mq-deadline for SSDs, none for NVMe (udev rules)
- **Boot** — systemd in initrd, zstd-compressed initramfs, wait-online disabled

### Developer Tooling

- **Editor** — Neovim
- **Shell** — Zsh with fzf, zoxide, bat, ripgrep, dircolors
- **Git** — Lazygit, delta diffs, GPG signing, global gitignore/gitattributes
- **Containers** — Docker with live-restore, log rotation, weekly prune
- **Environments** — direnv + devshell for per-project toolchains
- **AI** — Ollama

---

## Flake Inputs

| Input | Purpose |
|---|---|
| [`nixpkgs`](https://github.com/NixOS/nixpkgs) | Package set (`nixos-unstable`) |
| [`flake-parts`](https://github.com/hercules-ci/flake-parts) | Modular flake outputs |
| [`home-manager`](https://github.com/nix-community/home-manager) | User environment management |
| [`disko`](https://github.com/nix-community/disko) | Declarative disk partitioning |
| [`sops-nix`](https://github.com/Mic92/sops-nix) | Age-encrypted secrets |
| [`easy-hosts`](https://github.com/tgirlcloud/easy-hosts) | Multi-host flake helper |
| [`spicetify-nix`](https://github.com/Gerg-L/spicetify-nix) | Spotify theming |

---

## CI / Automation

| Workflow | Trigger | Description |
|---|---|---|
| **Validate** | Push / PR | `nix flake check` + flake input validation |
| **Format** | Push / PR | `nix fmt` via treefmt → auto-PR + merge on push |
| **Release ISO** | Tag `v*` / manual | Build installer ISO → GitHub Release with checksums |
| **Update flake inputs** | Weekly (Sun) | `update-flake-lock` → auto-PR + merge |
| **Update submodules** | Daily | `git submodule update --remote` → auto-PR + merge |
| **Dependabot** | Weekly | Keep GitHub Actions versions current |

---

## License

[MIT](LICENSE) © Harshal Sawant
