.PHONY: help rebuild home check fmt clean partition install-nix install-nixos mount-rescue troubleshoot
MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := help

HOST ?= $(shell hostname)
DISK ?= /dev/nvme0n1
MNT  ?= /mnt
USER ?= $(shell whoami)

CMD := $(firstword $(MAKECMDGOALS))
ARG := $(word 2,$(MAKECMDGOALS))
ifneq ($(filter rebuild home install-nixos,$(CMD)),)
  ifeq ($(HOST),$(shell hostname))
    ifneq ($(ARG),)
      HOST := $(ARG)
      .PHONY: $(ARG)
$(ARG):
	@:
    endif
  endif
endif

help: ## Show this help
	@printf "\033[1mUsage:\033[0m make \033[36m<target>\033[0m [HOST=<host>]\n\n"
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) \
		| awk -F ':.*## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@printf "\nDefaults:  HOST=%s  USER=%s  DISK=%s\n" "$(HOST)" "$(USER)" "$(DISK)"

rebuild: _need-host ## NixOS rebuild switch
	sudo nixos-rebuild switch --flake ".#$(HOST)"

home: _need-host ## Home Manager switch (standalone)
	home-manager switch --flake ".#$(USER)@$(HOST)"

partition: ## Partition + format + mount (DESTRUCTIVE)
	sudo nix run .#partition -- $(DISK) $(MNT)

install-nix: ## Install Nix package manager (multi-user)
	nix run .#install-nix

install-nixos: _need-host ## Run nixos-install from local flake
	sudo nixos-install --flake ".#$(HOST)" --no-root-passwd

mount-rescue: ## Mount BTRFS subvolumes for rescue
	sudo nix run .#mount-rescue -- $(MNT)

troubleshoot: ## Mount + enter NixOS rescue environment
	sudo nix run .#troubleshoot -- $(MNT)

swap-on: ## Create temporary swapfile for installation
	sudo nix run .#swap-on -- $(MNT)

swap-off: ## Remove temporary swapfile
	sudo nix run .#swap-off -- $(MNT)

check: ## Flake check (all systems)
	nix flake check --all-systems

fmt: ## Format all Nix files
	nix fmt

clean: ## GC + optimise Nix store
	sudo nix-collect-garbage -d
	nix store optimise

_need-host:
	@test -n "$(HOST)" || { echo "Usage: make $(CMD) HOST=<host>"; exit 1; }
