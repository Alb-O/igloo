# NixOS System Configuration Management
# Run `just` to see available commands

# Default hostname (can be overridden)
hostname := env_var_or_default('HOSTNAME', 'desktop')

# List all available commands
default:
    @just --list

# Rebuild NixOS system configuration
rebuild host=hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Rebuilding system configuration for host: {{host}}"
    # Source environment variables if .env exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    sudo -E nixos-rebuild switch --flake .#{{host}} --impure

# Rebuild with verbose output
rebuild-verbose host=hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    # Source environment variables if .env exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    sudo -E nixos-rebuild switch --flake .#{{host}} --show-trace --verbose --impure

# Test build without activation
test host=hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    # Source environment variables if .env exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    sudo -E nixos-rebuild test --flake .#{{host}} --impure

# Build configuration without switching
build host=hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    # Source environment variables if .env exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    # Pass environment variables to sudo and use impure mode
    sudo -E nixos-rebuild build --flake .#{{host}} --impure

# Check flake validity and build
check:
    #!/usr/bin/env bash
    set -euo pipefail
    # Source environment variables if .env exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    nix flake check --impure

# Format all Nix files
fmt:
    nix fmt

# Update flake inputs
update:
    nix flake update

# Update specific input
update-input input:
    nix flake update {{input}}

# Start Nix REPL with flake
repl:
    nix repl --file flake.nix

# Enter development shell
dev:
    nix develop

# Clean build artifacts
clean:
    rm -rf result result-*

# Garbage collect old generations
gc:
    sudo nix-collect-garbage -d

# List system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Show system information
info:
    @echo "System: $(uname -a)"
    @echo "Nix version: $(nix --version)"
    @echo "Available hosts:"
    @nix eval --json .#nixosConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No hosts found"

# Boot into specific generation
boot-generation gen:
    sudo nixos-rebuild switch --rollback --generation {{gen}}

# Set current directory as default build location
init:
    @echo "Setting up NixOS configuration directory..."
    @echo "Current directory: $(pwd)"
    @echo "Run 'just rebuild' to build the desktop configuration"

# Show flake info
show:
    nix flake show

# Build ISO image
iso host=hostname:
    nix build .#nixosConfigurations.{{host}}.config.system.build.isoImage