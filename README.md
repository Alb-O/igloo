# Generic NixOS Configuration Template

A portable NixOS and Home Manager configuration template designed for easy customization and sharing. All personal information is managed through environment variables, making it safe to use as a public template.

## Features

- Environment-based configuration (no personal data in repository)
- Multi-machine support with generic host directories
- Dynamic user and system configuration
- Theme and preference management via environment variables
- WSL and desktop support
- Automated rebuild and bootstrap scripts

## Quick Start

### 1. Clone and Setup
```bash
git clone <this-repo-url> ~/nix-config
cd ~/nix-config
cp .env.template .env
```

### 2. Configure Environment
Edit `.env` with your personal settings:
```bash
# Personal Information
NAME="Your Full Name"
EMAIL="your.email@example.com"
USERNAME="your-username"

# System Configuration
HOSTNAME="nixos"  # For WSL, or your actual hostname for bare metal
MACHINE_ID="nixos"  # Maps to directory: nixos, desktop, laptop

# Localization
TIMEZONE="UTC"
DEFAULT_LOCALE="en_US.UTF-8"
LC_LOCALE="en_US.UTF-8"

# Themes
THEME="vscode"
GTK_THEME="Adwaita-dark"
ICON_THEME="Adwaita"
CURSOR_THEME="Adwaita"
```

### 3. Bootstrap (First Time)
```bash
# For WSL
./scripts/bin/bootstrap nixos

# For desktop systems
./scripts/bin/bootstrap your-hostname
```

### 4. Regular Usage
```bash
# Rebuild home manager (most common)
./scripts/bin/rebuild

# Full system rebuild
./scripts/bin/rebuild --full

# Development mode (faster)
./scripts/bin/rebuild --dev
```

## Directory Structure

```
nix-config/
├── flake.nix              # Main configuration
├── .env                   # Your personal settings (gitignored)
├── .env.template          # Template for new users
├── lib/
│   ├── bootstrap.nix      # Environment loading
│   ├── globals.nix        # Configuration generator
│   └── themes/            # Theme system
├── nixos/
│   ├── hosts/
│   │   ├── desktop/       # Desktop machine config
│   │   ├── laptop/        # Laptop machine config
│   │   └── nixos/         # WSL config
│   └── modules/           # Shared NixOS modules
├── home-manager/
│   └── modules/           # Application configurations
└── scripts/
    ├── bin/rebuild        # Main rebuild script
    └── lib/               # Utility scripts
```

## Environment Variables

### Required Variables
- `NAME` - Your full name
- `EMAIL` - Your email address
- `USERNAME` - System username
- `HOSTNAME` - System hostname
- `MACHINE_ID` - Which config directory to use (desktop, laptop, nixos)

### Optional Variables
- `TIMEZONE` - Your timezone (default: UTC)
- `DEFAULT_LOCALE` - System locale (default: en_US.UTF-8)
- `LC_LOCALE` - Locale for regional settings
- `THEME` - Color theme (vscode, catppuccin, helix)
- `GTK_THEME`, `ICON_THEME`, `CURSOR_THEME` - UI themes
- `GEMINI_API_KEY`, `OPENAI_API_KEY` - For AI features

## Machine Configuration

The system uses `MACHINE_ID` to map to configuration directories:

- **WSL Machine**: `HOSTNAME="nixos"`, `MACHINE_ID="nixos"`
- **Desktop Machine**: `HOSTNAME="your-desktop"`, `MACHINE_ID="desktop"`
- **Laptop Machine**: `HOSTNAME="your-laptop"`, `MACHINE_ID="laptop"`

This allows multiple physical machines to share the same repository while using appropriate configurations.

## Usage

### Rebuild Commands
```bash
# Home manager only (default)
./scripts/bin/rebuild

# Full system rebuild
./scripts/bin/rebuild --full

# With specific user/host
./scripts/bin/rebuild --user username

# Verbose output
./scripts/bin/rebuild --verbose

# Auto-commit changes
./scripts/bin/rebuild --auto-commit
```

### Development Tools
```bash
# Format Nix files
./scripts/bin/dev-tools format

# Validate configuration
./scripts/bin/dev-tools validate

# Update flake inputs
./scripts/bin/dev-tools update

# Clean old generations
./scripts/bin/dev-tools clean
```

### Manual Commands
```bash
# Direct home manager
nix run github:nix-community/home-manager/master -- switch --flake .#user@host

# Direct NixOS rebuild
sudo nixos-rebuild switch --flake .#hostname

# Check flake validity
nix flake check
```

## Customization

### Adding New Machines
1. Copy `.env.template` to `.env`
2. Set `HOSTNAME` to your machine's hostname
3. Set `MACHINE_ID` to the appropriate config directory
4. Run bootstrap script

### Adding New Machine Types
1. Create directory in `nixos/hosts/new-type/`
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Set `MACHINE_ID="new-type"` in your `.env`

### Modifying Themes
Available themes are in `lib/themes/`. Set `THEME` environment variable to switch between them.

## Security

- `.env` file is gitignored and never committed
- API keys and personal information stay local
- Safe defaults provided in `.env.template`
- No hardcoded personal data in repository files

## Troubleshooting

### Build Failures
```bash
# Check configuration
nix flake check

# Verify environment
cat .env

# Clean and retry
nix-collect-garbage -d
./scripts/bin/rebuild
```

### Permission Issues
```bash
# Secure .env file
chmod 600 .env

# Reset if needed
git stash
git pull origin main
```

### Locale Errors
Ensure your locale settings in `.env` use supported locales. Check available locales with `locale -a`.

## Git Workflow

- Auto-fixup commits: The rebuild tool creates a small fixup commit before every rebuild to keep the working tree clean (prevents Nix complaining about a dirty tree). These commits target a temporary `baseline(auto)` commit and are autosquashed later.
- True commit with autosquash:
  - `./scripts/bin/true-commit -m "Your message"` — squashes all auto fixups into the last non-fixup commit and replaces its message with the one you provide.
  - If there are uncommitted changes, they are included automatically as a fixup before squashing.
  - A fresh `baseline(auto)` empty commit is created after each true commit, so future autosaves never overwrite previous true commits.
