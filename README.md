# NixOS Configuration

## Usage

NixOS system configuration:
```bash
just system-rebuild    # defaults to host "desktop"
# or short alias
just rebuild
```

Home Manager configuration (pick a defined target, e.g. `default@desktop`):
```bash
just home-switch default@desktop
# or short alias
just switch default@desktop
```

## Structure

```
├── flake.nix          # NixOS + Home Manager flake
├── justfile           # Unified build tasks (system + home)
├── nixos/             # NixOS modules and hosts
└── home-manager/      # Home Manager configuration
    └── modules/       # Home Manager modules
```

## Configuration

- Copy `lib/users.local.nix.example` to `lib/users.local.nix` and set your primary user.
- Use the predefined hosts in `lib/hosts.nix` (desktop/server) or add more.
- The flake automatically adds `"<username>@desktop"` if `primary` is defined.

## Commands

### System (NixOS)
```bash
just system-rebuild          # Rebuild (host: desktop)
just system-rebuild server   # Rebuild specific host
just system-test             # Test build
just system-check            # Check system config
```

### Home Manager
```bash
just home-switch default@desktop   # Build and switch default user
just home-switch john@desktop      # If you set primary.username = "john"
just home-build  default@desktop   # Build only
just home-check                    # Check home config
```

### Shared
```bash
just                     # List all commands
just update              # Update flake inputs
just fmt                 # Format all files
just gc                  # Clean old generations
just check-all           # Check both configurations
```

## Machine Types

Hosts are declared in `lib/hosts.nix`. Provided:
- `desktop` – graphical workstation
- `server` – headless/WSL

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
