# NixOS Configuration

NixOS and Home Manager configurations in a single repository with independent build systems.

## Usage

NixOS system configuration:
```bash
just system-rebuild
# or short alias
just rebuild
```

Home Manager configuration:
```bash
just home-switch
# or short alias
just switch
```

## Structure

```
├── flake.nix          # NixOS configuration
├── justfile           # Unified build tasks (system + home)
├── nixos/             # NixOS modules and hosts
└── home-manager/      # Home Manager configuration
    ├── flake.nix      # Home Manager flake
    └── modules/       # Home Manager modules
```

## Configuration

Copy `.env.template` to `.env` and set required variables:

```bash
# Required
NAME="Your Name"
EMAIL="your.email@example.com"
USERNAME="your-username"
HOSTNAME="nixos"
MACHINE_ID="nixos"  # desktop, laptop, or nixos

# Optional
TIMEZONE="UTC"
```

## Commands

### System (NixOS)
```bash
just system-rebuild       # Rebuild system
just system-rebuild desktop # Rebuild specific host
just system-test          # Test build
just system-check         # Check system config
```

### Home Manager
```bash
just home-switch         # Build and switch
just home-switch-full    # Build user@hostname
just home-check          # Check home config
```

### Shared
```bash
just                     # List all commands
just update              # Update both system and home inputs
just fmt                 # Format all files
just gc                  # Clean old generations
just check-all           # Check both configurations
```

### Aliases
```bash
just rebuild             # Alias for system-rebuild
just switch              # Alias for home-switch
```

## Machine Types

Set `MACHINE_ID` to match your configuration:
- `nixos` - WSL configuration
- `desktop` - Desktop machine
- `laptop` - Laptop machine

## Troubleshooting

Check configuration:
```bash
nix flake check
```

Clean and rebuild:
```bash
nix-collect-garbage -d
just rebuild
```
