.PHONY: help rebuild rebuild-home rebuild-verbose test check format clean

# Load environment variables from .env file if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Default hostname and username (use environment variables or fallback)
HOSTNAME ?= desktop
USERNAME ?= $(shell whoami)

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

rebuild: ## Rebuild NixOS configuration (HOSTNAME=desktop)
	@./scripts/rebuild.sh $(HOSTNAME)


rebuild-verbose: ## Rebuild with verbose output
	@./scripts/rebuild.sh $(HOSTNAME) --verbose

test: ## Test flake validity
	nix flake check

format: ## Format all Nix files
	nix fmt

update: ## Update flake inputs
	nix flake update

repl: ## Start Nix REPL with current flake
	nix repl --file flake.nix

shell: ## Enter development shell
	nix develop

gc: ## Run garbage collection
	nix-collect-garbage -d

build-iso: ## Build NixOS ISO
	nix build .#nixosConfigurations.$(HOSTNAME).config.system.build.isoImage

clean: ## Clean build artifacts
	@rm -rf result result-*