# NixOS Dotfiles

This repository contains my NixOS and Nix configuration, managed as a flake for reproducibility and declarative system management.

---

## What is Nix & NixOS?

- **Nix**: A purely functional package manager. It ensures reproducible, dependency-isolated environments.
- **NixOS**: A Linux distribution built on top of Nix, allowing you to declaratively configure your entire system.

### Why Use Nix/NixOS?
- **Reproducibility**: Your system and packages are defined in code.
- **Atomic Upgrades & Rollbacks**: Safe system updates and easy rollback if something breaks.
- **Multi-user, Multi-version**: Install multiple versions of packages side-by-side.
- **Declarative Configuration**: Define your system, packages, and services in a single configuration file.

---

## Usage

### 1. Install Nix (multi-user)
```bash
make install-nix
```

### 2. Partition & Mount (DESTRUCTIVE)
```bash
make partition
```

### 3. Install NixOS
```bash
make install-nixos HOST=<hostname>
```
Replace `<hostname>` with your desired hostname (e.g., `laptop`).

### 4. Rebuild NixOS
```bash
make rebuild HOST=<hostname>
```

### 5. Home Manager (user environment)
```bash
make home HOST=<hostname>
```

### 6. Check Flake
```bash
make check
```

### 7. Format Nix Files
```bash
make fmt
```

### 8. Clean Nix Store
```bash
make clean
```

### 9. Troubleshooting
```bash
make troubleshoot
```
Mounts your system and drops you into a rescue shell.

---

## Notes
- All commands use flakes and the new Nix command.
- For more details, see the [NixOS Wiki](https://nixos.wiki/) and [NixOS Manual](https://nixos.org/manual/nixos/stable/).
