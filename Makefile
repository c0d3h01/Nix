.PHONY: help rebuild home check fmt clean partition install-nix install-nixos mount-rescue troubleshoot swap-on swap-off
MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := help

HOST ?= $(shell hostname)
DISK ?= /dev/nvme0n1
MNT  ?= /mnt
USER ?= $(shell whoami)

NIX_EXPERIMENTAL := --extra-experimental-features "nix-command flakes"

help: ## Show this help
	@echo "Usage: make <target> [HOST=<host>]"
	@echo ""
	@echo "Targets:"
	@echo "  rebuild          NixOS rebuild switch"
	@echo "  home             Home Manager switch (standalone)"
	@echo "  partition        Partition + format + mount (DESTRUCTIVE)"
	@echo "  install-nix      Install Nix package manager (multi-user)"
	@echo "  install-nixos    Run nixos-install from local flake"
	@echo "  mount-rescue     Mount BTRFS subvolumes for rescue"
	@echo "  troubleshoot     Mount + enter NixOS rescue environment"
	@echo "  swap-on          Create temporary swapfile for installation"
	@echo "  swap-off         Remove temporary swapfile"
	@echo "  check            Flake check (all systems)"
	@echo "  fmt              Format all Nix files"
	@echo "  clean            GC + optimise Nix store"
	@echo ""
	@echo "Defaults:"
	@echo "  HOST=$(HOST)"
	@echo "  USER=$(USER)"
	@echo "  DISK=$(DISK)"

rebuild: _need-host
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home: _need-host
	home-manager $(NIX_EXPERIMENTAL) switch --flake ".#$(USER)@$(HOST)"

partition:
	sudo nix $(NIX_EXPERIMENTAL) run .#partition -- $(DISK) $(MNT)

install-nix:
	nix $(NIX_EXPERIMENTAL) run .#install-nix

install-nixos: _need-host
	sudo nix $(NIX_EXPERIMENTAL) run .#nixos-install -- --flake ".#$(HOST)" --no-root-passwd

mount-rescue:
	sudo nix $(NIX_EXPERIMENTAL) run .#mount-rescue -- $(MNT)

troubleshoot:
	sudo nix $(NIX_EXPERIMENTAL) run .#troubleshoot -- $(MNT)

swap-on:
	sudo nix $(NIX_EXPERIMENTAL) run .#swap-on -- $(MNT)

swap-off:
	sudo nix $(NIX_EXPERIMENTAL) run .#swap-off -- $(MNT)

check:
	nix $(NIX_EXPERIMENTAL) flake check --all-systems

fmt:
	nix $(NIX_EXPERIMENTAL) fmt

clean:
	sudo nix-collect-garbage -d
	nix $(NIX_EXPERIMENTAL) store optimise

_need-host:
	@test -n "$(HOST)" || { echo "Usage: make $(CMD) HOST=<host>"; exit 1; }
