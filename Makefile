HOST ?= nixos
DISK ?= /dev/nvme0n1
USER ?= $(shell whoami)

MAKEFLAGS += --no-print-directory
NIX_FLAGS := --extra-experimental-features "nix-command flakes"

.PHONY: help rebuild home install-disko install-nixos check fmt clean

help:
	@echo "Usage: make <target> [HOST=<host>]"
	@echo "Defaults: HOST=$(HOST), USER=$(USER), DISK=$(DISK)"
	@echo "Targets: rebuild, home, install-disko, install-nixos, check, fmt, clean"

rebuild:
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home:
	home-manager $(NIX_FLAGS) switch --flake ".#$(USER)@$(HOST)"

install-disko:
	sudo nix --experimental-features "nix-command flakes" run \
		github:nix-community/disko/latest -- \
		--mode destroy,format,mount \
		--yes-wipe-all-disks \
		--flake "github:anon/Nix#$(HOST)"

install-nixos:
	sudo nixos-install --flake ".#$(HOST)" --no-root-passwd

check:
	nix $(NIX_FLAGS) flake check --all-systems

fmt:
	nix $(NIX_FLAGS) fmt .

clean:
	sudo nix-collect-garbage -d
	nix $(NIX_FLAGS) store optimise
