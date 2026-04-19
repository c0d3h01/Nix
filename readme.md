# Nix

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
