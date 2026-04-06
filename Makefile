HOST ?= firus
DISK ?= /dev/nvme0n1
MNT  ?= /mnt
USER ?= $(shell whoami)

MAKEFLAGS += --no-print-directory
NIX_FLAGS := --extra-experimental-features "nix-command flakes"

.PHONY: help rebuild home partition install-nix install-nixos mount-rescue troubleshoot check fmt clean

help:
	@echo "Usage: make <target> [HOST=<host>]"
	@echo "Defaults: HOST=$(HOST), USER=$(USER), DISK=$(DISK)"
	@echo "Targets: rebuild, home, partition, install-nix, install-nixos, mount-rescue, troubleshoot, check, fmt, clean"

rebuild:
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home:
	home-manager $(NIX_FLAGS) switch --flake ".#$(USER)@$(HOST)"

partition:
	sudo nix $(NIX_FLAGS) run .#partition -- $(DISK) $(MNT)

install-nix:
	nix $(NIX_FLAGS) run .#install-nix

install-disko:
	sudo nix --experimental-features "nix-command flakes" run \
		github:nix-community/disko/latest -- \
		--mode destroy,format,mount \
		--yes-wipe-all-disks \
		--flake "github:c0d3h01/nix#firus"

install-nixos:
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
