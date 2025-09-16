# NixOS and Home Manager Configuration Management
# Run `just` to see available commands

# No .env sourcing; keep things pure.
# Avoid shell lookups that can fail when user is missing from passwd.
user := env_var_or_default('USER', 'unknown')
hostname := env_var_or_default('HOSTNAME', 'unknown')
home_default := `nix eval --json path:.#homeConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[0]'`

# List all available commands
default:
    @just --list

# ========================================
# SYSTEM - NixOS Configuration Management
# ========================================

# Rebuild NixOS system configuration
system-rebuild host="desktop":
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_HOST="{{host}}"
    echo "Rebuilding system configuration for host: $TARGET_HOST"
    sudo -E nixos-rebuild switch --flake path:.#$TARGET_HOST

# Rebuild with verbose output
system-rebuild-verbose host="desktop":
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_HOST="{{host}}"
    sudo -E nixos-rebuild switch --flake path:.#$TARGET_HOST --show-trace --verbose

# Test build without activation
system-test host="desktop":
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_HOST="{{host}}"
    sudo -E nixos-rebuild test --flake path:.#$TARGET_HOST

# Build configuration without switching
system-build host="desktop":
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_HOST="{{host}}"
    sudo -E nixos-rebuild build --flake path:.#$TARGET_HOST

# Check system flake validity
system-check:
    #!/usr/bin/env bash
    set -euo pipefail
    nix flake check path:.

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
    @nix eval --json path:.#nixosConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No hosts found"

# Build ISO image
system-iso host="desktop":
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_HOST="{{host}}"
    nix build path:.#nixosConfigurations.$TARGET_HOST.config.system.build.isoImage

# =====================================
# HOME - Home Manager Configuration
# =====================================

# Build and activate home-manager configuration
home-switch target=home_default:
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{target}}"
    AVAIL=$(nix eval --json path:.#homeConfigurations --apply builtins.attrNames)
    if ! echo "$AVAIL" | jq -e --arg t "$TARGET" '.[] | select(. == $t)' >/dev/null; then
      echo "Unknown home target '$TARGET'. Available:" >&2
      echo "$AVAIL" | jq -r '.[]' | sed 's/^/  /' >&2
      exit 1
    fi
    nix run github:nix-community/home-manager/master -- switch --flake "path:.#${TARGET}" --impure

# Build configuration without activation
home-build target=home_default:
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{target}}"
    AVAIL=$(nix eval --json path:.#homeConfigurations --apply builtins.attrNames)
    if ! echo "$AVAIL" | jq -e --arg t "$TARGET" '.[] | select(. == $t)' >/dev/null; then
      echo "Unknown home target '$TARGET'. Available:" >&2
      echo "$AVAIL" | jq -r '.[]' | sed 's/^/  /' >&2
      exit 1
    fi
    home-manager build --flake "path:.#${TARGET}" --impure

# Check home-manager flake validity  
home-check:
    #!/usr/bin/env bash
    set -euo pipefail
    nix flake check path:.

# List home-manager generations
home-generations:
    home-manager generations

# Show home-manager configuration info
home-info:
    @echo "User: {{user}}"
    @echo "Hostname: {{hostname}}"
    @echo "Home Manager version: $(home-manager --version 2>/dev/null || echo 'not installed')"
    @echo "Available configurations:"
    @nix eval --json path:.#homeConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No configurations found"

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
    nix flake show path:.

# Show home-manager flake info
home-show:
    nix flake show path:.

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
        nix run ./flakes/nixCats-fish
    elif [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/flakes/nixCats-fish/config" ]; then
        export NIXCATS_FISH_DIR="$FLAKE_ROOT/flakes/nixCats-fish/config"  
        nix run $FLAKE_ROOT/flakes/nixCats-fish
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
        nix run ./flakes/nixCats-bash
    elif [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/flakes/nixCats-bash/rc" ]; then
        export NIXCATS_BASH_DIR="$FLAKE_ROOT/flakes/nixCats-bash/rc"  
        nix run $FLAKE_ROOT/flakes/nixCats-bash  
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
