.PHONY: help rebuild home check fmt clean
MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := help

# ── Defaults ──────────────────────────────────────────────────────────────
HOST ?= $(shell hostname)
USER ?= $(shell whoami)

# ── Positional shorthand: `make rebuild laptop` ──────────────────────────
CMD := $(firstword $(MAKECMDGOALS))
ARG := $(word 2,$(MAKECMDGOALS))
ifneq ($(filter rebuild home,$(CMD)),)
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
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) \
		| awk -F ':.*## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@printf "\nDefaults:  HOST=%s  USER=%s\n" "$(HOST)" "$(USER)"

rebuild: _need-host ## NixOS rebuild switch
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home: _need-host ## Home Manager switch
	home-manager switch --flake ".#$(USER)@$(HOST)"


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
