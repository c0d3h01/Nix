# NixOS Dotfiles

Declarative NixOS workstation configuration with reusable NixOS and Home Manager modules.

## Scope

This repository defines system configuration, user environment, and encrypted secret integration in one flake.

## Repository Layout

- `flake.nix`: Flake entry point and outputs wiring.
- `hosts/`: Host-specific entries and hardware files.
- `modules/nixos/`: System-level modules.
- `modules/home/`: Home Manager modules.
- `secrets/`: Encrypted secrets managed through sops-nix.

## Workflow

All operational commands are centralized in `Makefile`.
