.PHONY: help home rebuild clean check

DEFAULT_HOST ?= $(shell hostname)
USER_NAME ?= $(shell whoami)

.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo "  make home HOST=<host>      # Home Manager switch for host"
	@echo "  make rebuild HOST=<host>   # NixOS rebuild switch for host"
	@echo "  make clean                 # GC + optimize Nix store"
	@echo "  make check                 # Flake check for all systems"
	@echo ""
	@echo "Defaults:"
	@echo "  DEFAULT_HOST=$(DEFAULT_HOST)"
	@echo "  USER_NAME=$(USER_NAME)"

home:
	@test -n "$(HOST)" || (echo "Usage: make home HOST=<host>" && exit 1)
	@echo "Switching Home Manager for $(HOST)..."
	home-manager switch --flake ".#$(HOST)"

rebuild:
	@test -n "$(HOST)" || (echo "Usage: make rebuild HOST=<host>" && exit 1)
	@echo "Rebuilding NixOS for $(HOST)..."
	sudo nixos-rebuild switch --flake ".#$(HOST)"

clean:
	@echo "Cleaning up Nix store..."
	sudo nix-collect-garbage -d
	nix store optimise

check:
	@echo "Checking for all systems..."
	nix flake check --all-systems
