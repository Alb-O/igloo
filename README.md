# NixOS Configuration

## Usage

NixOS system configuration:
```bash
just system-rebuild    # defaults to host "desktop"
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
├── flake.nix          # NixOS + Home Manager flake
├── justfile           # Unified build tasks (system + home)
├── nixos/             # NixOS modules and hosts
└── home-manager/      # Home Manager configuration
    └── modules/       # Home Manager modules
```

## Configuration

- The flake ships with anonymised defaults for the primary user and the `desktop`/`server` hosts.
- Copy `overrides/personal.nix.example` to `overrides/personal.nix` and fill in your real details (the file is gitignored and loaded automatically).
- The Home Manager target name is derived from `username@hostname`; rerun `just home-switch` after editing the override and it will pick up the new attr.
- Home Manager expects the runtime user to match the configured username—make sure your override is in place before running `home-manager switch` or `just home-switch`.

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
just home-switch                   # Build and switch (uses override or defaults)
just home-build                    # Build only
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

Hosts are defined inline in `flake.nix`. Provided:
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
