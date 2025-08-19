# NixOS Configuration

NixOS and Home Manager configurations in a single repository with independent build systems.

## Usage

NixOS system configuration:
```bash
just rebuild
```

Home Manager configuration:
```bash
cd home-manager
just switch
```

## Structure

```
├── flake.nix          # NixOS configuration
├── justfile           # NixOS build tasks
├── nixos/             # NixOS modules and hosts
└── home-manager/      # Home Manager configuration
    ├── flake.nix      # Home Manager flake
    ├── justfile       # Home Manager build tasks
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
THEME="vscode"
```

## Commands

### NixOS
```bash
just                    # List commands
just rebuild           # Rebuild system
just rebuild desktop   # Rebuild specific host
just test              # Test build
just update            # Update inputs
```

### Home Manager
```bash
cd home-manager
just switch            # Build and switch
just switch-full       # Build user@hostname
just update            # Update inputs
```

### Development
```bash
just fmt               # Format files
just check             # Validate configuration
just gc                # Clean old generations
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