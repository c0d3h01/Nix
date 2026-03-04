.PHONY: help rebuild home check fmt clean install-nix install-disko install-nixos
MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := help

# ── Defaults ──────────────────────────────────────────────────────────────
HOST ?= $(shell hostname)
INSTALL_FLAKE ?= github:c0d3h01/nix-dotfiles#$(HOST)
USER ?= $(shell whoami)

# ── Positional shorthand: `make rebuild laptop` ──────────────────────────
CMD := $(firstword $(MAKECMDGOALS))
ARG := $(word 2,$(MAKECMDGOALS))
ifneq ($(filter rebuild home install-disko install-nixos,$(CMD)),)
  ifeq ($(HOST),$(shell hostname))
    ifneq ($(ARG),)
      HOST := $(ARG)
      .PHONY: $(ARG)
$(ARG):
	@:
    endif
  endif
endif

# ── Targets ───────────────────────────────────────────────────────────────
help: ## Show this help
	@printf "\033[1mUsage:\033[0m make \033[36m<target>\033[0m [HOST=<host>]\n\n"
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) \
		| awk -F ':.*## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@printf "\nDefaults:  HOST=%s  USER=%s\n" "$(HOST)" "$(USER)"

rebuild: _need-host ## NixOS rebuild switch
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home: _need-host ## Home Manager switch
	home-manager switch --flake ".#$(USER)@$(HOST)"

install-nix: ## Install Nix package manager (multi-user)
	curl -L https://nixos.org/nix/install | sh -s -- --daemon

install-disko: _need-host ## Disko destroy/format/mount for INSTALL_FLAKE (DESTRUCTIVE)
	sudo nix --experimental-features "nix-command flakes" run \
		github:nix-community/disko/latest -- \
		--mode destroy,format,mount \
		--yes-wipe-all-disks \
		--flake "$(INSTALL_FLAKE)"

install-nixos: _need-host ## Run nixos-install for INSTALL_FLAKE
	sudo nixos-install --flake "$(INSTALL_FLAKE)" --no-root-passwd


check: ## Flake check (all systems)
	nix flake check --all-systems

fmt: ## Format all Nix files
	nix fmt

clean: ## GC + optimise Nix store
	sudo nix-collect-garbage -d
	nix store optimise

# ── Helpers ───────────────────────────────────────────────────────────────
_need-host:
	@test -n "$(HOST)" || { echo "Usage: make $(CMD) HOST=<host>"; exit 1; }
