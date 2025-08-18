# Home Manager Configuration Management  
# Run `just` to see available commands

# Load environment variables from .env file if it exists
set dotenv-load := true

# Default user and hostname with env file fallbacks
user := env_var_or_default('USERNAME', env_var_or_default('USER', 'user'))
hostname := env_var_or_default('HOSTNAME', `hostname`)

# List all available commands
default:
    @just --list

# Build and activate home-manager configuration
switch config=user:
    USER={{config}} HOME=/home/{{config}} nix run github:nix-community/home-manager/master -- switch --flake .#{{config}} --impure

# Build home-manager configuration with full path (user@hostname)
switch-full:
    USER={{user}} HOME=/home/{{user}} nix run github:nix-community/home-manager/master -- switch --flake .#{{user}}@{{hostname}} --impure

# Build configuration without activation
build config=user:
    home-manager build --flake .#{{config}} --impure

# Check flake validity
check:
    nix flake check

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
    nix-collect-garbage -d

# List home-manager generations
generations:
    home-manager generations

# Show configuration info
info:
    @echo "User: {{user}}"
    @echo "Hostname: {{hostname}}"
    @echo "Home Manager version: $(home-manager --version)"
    @echo "Available configurations:"
    @nix eval --impure --json .#homeConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' | sed 's/^/  /' || echo "  No configurations found"

# Show flake info
show:
    nix flake show

# Show home-manager news
news:
    home-manager news

# Remove a specific generation
remove-generation gen:
    home-manager remove-generations {{gen}}

# Edit configuration with your editor
edit:
    $EDITOR home.nix

# Quick rebuild (same as switch but shorter)
build-quick config=user:
    @just switch {{config}}