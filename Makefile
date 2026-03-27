HOST ?= $(shell hostname)
DISK ?= /dev/nvme0n1
MNT  ?= /mnt
USER ?= $(shell whoami)

MAKEFLAGS += --no-print-directory

NIX_FLAGS := --extra-experimental-features "nix-command flakes"

.PHONY: help rebuild home partition install-nix install-nixos mount-rescue troubleshoot check fmt clean

help: ## Show this help
	@echo "Usage: make <target> [HOST=<host>]"
	@echo ""
	@echo "Targets:"
	@echo "  rebuild          NixOS rebuild switch"
	@echo "  home             Home Manager switch (standalone)"
	@echo "  partition        Partition + format + mount (DESTRUCTIVE)"
	@echo "  install-nix      Install Nix package manager (multi-user)"
	@echo "  install-nixos    Run nixos-install from local flake"
	@echo "  mount-rescue     Mount filesystems for rescue"
	@echo "  troubleshoot     Mount + enter NixOS rescue environment"
	@echo "  check            Flake check (all systems)"
	@echo "  fmt              Format all Nix files"
	@echo "  clean            GC + optimise Nix store"
	@echo ""
	@echo "Defaults: HOST=$(HOST), USER=$(USER), DISK=$(DISK)"

rebuild:
	@test -n "$(HOST)" || { echo "Error: HOST is empty"; exit 1; }
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home:
	@test -n "$(HOST)" || { echo "Error: HOST is empty"; exit 1; }
	home-manager $(NIX_FLAGS) switch --flake ".#$(USER)@$(HOST)"

partition:
	sudo nix $(NIX_FLAGS) run .#partition -- $(DISK) $(MNT)

install-nix:
	nix $(NIX_FLAGS) run .#install-nix

install-nixos:
	@test -n "$(HOST)" || { echo "Error: HOST is empty"; exit 1; }
	sudo nixos-install --flake ".#$(HOST)" --no-root-passwd

mount-rescue:
	sudo nix $(NIX_FLAGS) run .#mount-rescue -- $(MNT)

troubleshoot:
	sudo nix $(NIX_FLAGS) run .#troubleshoot -- $(MNT)

check:
	nix $(NIX_FLAGS) flake check --all-systems

fmt:
	nix $(NIX_FLAGS) fmt

clean:
	sudo nix-collect-garbage -d
	nix $(NIX_FLAGS) store optimise
