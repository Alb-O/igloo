# NixOS and Home Manager Configuration Management
# Run `just` to see available commands

# Load environment variables from .env file if it exists
set dotenv-load := true

# Default user and hostname with env file fallbacks
user := env_var_or_default('USERNAME', env_var_or_default('USER', 'user'))
hostname := env_var_or_default('HOSTNAME', `hostname`)

# List all available commands
default:
    @just --list

# ========================================
# SYSTEM - NixOS Configuration Management
# ========================================

# Rebuild NixOS system configuration
system-rebuild host="auto":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET_HOST=$( [ "{{host}}" = "auto" ] && echo "${HOSTNAME:-desktop}" || echo "{{host}}" )
    echo "Rebuilding system configuration for host: $TARGET_HOST"
    sudo -E nixos-rebuild switch --flake .#$TARGET_HOST --impure

# Rebuild with verbose output
system-rebuild-verbose host="auto":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET_HOST=$( [ "{{host}}" = "auto" ] && echo "${HOSTNAME:-desktop}" || echo "{{host}}" )
    sudo -E nixos-rebuild switch --flake .#$TARGET_HOST --show-trace --verbose --impure

# Test build without activation
system-test host="auto":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET_HOST=$( [ "{{host}}" = "auto" ] && echo "${HOSTNAME:-desktop}" || echo "{{host}}" )
    sudo -E nixos-rebuild test --flake .#$TARGET_HOST --impure

# Build configuration without switching
system-build host="auto":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET_HOST=$( [ "{{host}}" = "auto" ] && echo "${HOSTNAME:-desktop}" || echo "{{host}}" )
    sudo -E nixos-rebuild build --flake .#$TARGET_HOST --impure

# Check system flake validity
system-check:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    nix flake check --impure

# List system generations
system-generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Boot into specific generation
system-boot-generation gen:
    sudo nixos-rebuild switch --rollback --generation {{gen}}

# Show system information
system-info:
    @echo "System: $(uname -a)"
    @echo "Nix version: $(nix --version)"
    @echo "Available hosts:"
    @nix eval --json .#nixosConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No hosts found"

# Build ISO image
system-iso host="auto":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET_HOST=$( [ "{{host}}" = "auto" ] && echo "${HOSTNAME:-desktop}" || echo "{{host}}" )
    nix build .#nixosConfigurations.$TARGET_HOST.config.system.build.isoImage

# =====================================
# HOME - Home Manager Configuration
# =====================================

# Build and activate home-manager configuration
home-switch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    TARGET="${USERNAME}@${HOSTNAME}"
    env USER="${USERNAME}" HOME="/home/${USERNAME}" nix run github:nix-community/home-manager/master -- switch --flake ".#${TARGET}" --impure

# Build configuration without activation
home-build:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    home-manager build --flake ".#${USERNAME}@${HOSTNAME}" --impure

# Check home-manager flake validity  
home-check:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    nix flake check --impure

# List home-manager generations
home-generations:
    home-manager generations

# Show home-manager configuration info
home-info:
    @echo "User: {{user}}"
    @echo "Hostname: {{hostname}}"
    @echo "Home Manager version: $(home-manager --version 2>/dev/null || echo 'not installed')"
    @echo "Available configurations:"
    @nix eval --impure --json .#homeConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No configurations found"

# Show home-manager news
home-news:
    home-manager news

# Remove a specific home-manager generation
home-remove-generation gen:
    home-manager remove-generations {{gen}}

# Edit home configuration with your editor
home-edit:
    $EDITOR home-manager/home.nix

# ========================================
# SHARED - Common Development Tasks
# ========================================

# Format all Nix files
fmt:
    nix fmt

# Bump OpenCode to a specific version (or latest) and auto-fill hashes
opencode-bump version="latest":
    ./scripts/opencode-bump.sh {{version}}

# Update OpenCode to latest and switch
opencode-update:
    ./scripts/opencode-bump.sh latest
    just home-switch

# Update flake inputs
update:
    nix flake update

# Update specific input
update-input input:
    nix flake update {{input}}

# Start Nix REPL with system flake
repl:
    nix repl --file flake.nix

# Start Nix REPL with home-manager flake
home-repl:
    nix repl --file flake.nix

# Enter development shell
dev:
    nix develop

# Clean build artifacts
clean:
    rm -rf result result-*
    cd home-manager && rm -rf result result-*

# Garbage collect old generations
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Show flake info (system)
show:
    nix flake show

# Show home-manager flake info
home-show:
    nix flake show

# Check both system and home configurations
check-all:
    @just system-check
    @just home-check

# Set current directory as default build location
init:
    @echo "Setting up NixOS configuration directory..."
    @echo "Current directory: $(pwd)"
    @echo "Run 'just system-rebuild' to build the system configuration"
    @echo "Run 'just home-switch' to build the home configuration"

# ========================================
# SHELLS - Alternative Shell Environments  
# ========================================

# Launch nixCats-fish (modern Fish shell)  
fish:
    #!/usr/bin/env bash
    # Auto-discover nixCats-fish config location
    if [ -d "./flakes/nixCats-fish/config" ]; then
        export NIXCATS_FISH_DIR="$(pwd)/flakes/nixCats-fish/config"
        nix run ./flakes/nixCats-fish --impure
    elif [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/flakes/nixCats-fish/config" ]; then
        export NIXCATS_FISH_DIR="$FLAKE_ROOT/flakes/nixCats-fish/config"  
        nix run $FLAKE_ROOT/flakes/nixCats-fish --impure
    else
        echo "Error: nixCats-fish config not found!"
        echo "Make sure you're in the flake root directory or set FLAKE_ROOT"
        exit 1
    fi

# Launch nixCats-bash (ble.sh powered Bash)
bash:
    #!/usr/bin/env bash
    # Auto-discover nixCats-bash config location
    if [ -d "./flakes/nixCats-bash/rc" ]; then
        export NIXCATS_BASH_DIR="$(pwd)/flakes/nixCats-bash/rc"
        nix run ./flakes/nixCats-bash --impure
    elif [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/flakes/nixCats-bash/rc" ]; then
        export NIXCATS_BASH_DIR="$FLAKE_ROOT/flakes/nixCats-bash/rc"
        nix run $FLAKE_ROOT/flakes/nixCats-bash --impure  
    else
        echo "Error: nixCats-bash config not found!"
        echo "Make sure you're in the flake root directory or set FLAKE_ROOT"
        exit 1
    fi

# ========================================
# ALIASES - Shorter Commands
# ========================================

# Short aliases for common commands
alias rebuild := system-rebuild
alias switch := home-switch
alias s := home-switch
alias r := system-rebuild
