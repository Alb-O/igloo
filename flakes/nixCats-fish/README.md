# nixCats-fish

A Fish shell configuration manager inspired by [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim), bringing the same powerful category-based architecture to Fish shell management.

## Philosophy

**Nix is for downloading. Fish is for configuring.**

nixCats-fish follows the same core principle as nixCats-nvim: use Nix to manage dependencies and tooling, while keeping your Fish configuration in readable Fish scripts. The category system allows you to build multiple variations of your shell configuration from a single set of definitions.

## 🌟 Key Features

### 📦 **Category-Based Architecture**
- Define dependencies and features in categories
- Enable/disable entire feature sets per package
- Query enabled categories from Fish scripts with `fishCats <category>`

### 🔄 **Multiple Package Definitions**  
- `fishCats` - Full-featured configuration
- `minimalFish` - Minimal configuration for servers
- `devFish` - Development-focused live configuration

### 🎯 **Wrapped vs Unwrapped Modes**
- **Wrapped** (`wrapRc = true`): Immutable config from Nix store - perfect for reproducibility
- **Unwrapped** (`wrapRc = false`): Live-editable config - great for development and customization

### 🔍 **Runtime Querying**
- `fishCats fzf` - Check if fzf category is enabled
- `fishCats modern.core` - Check subcategories  
- `fishCats --list` - List all enabled categories
- `fishCats --get theme` - Get values from extra config

### 🎨 **Theme-Aware Configuration**
- Automatic color schemes based on theme selection
- FZF integration respects theme colors
- Consistent theming across all components

## 🚀 Quick Start

### Try It Now
```bash
# Try the full configuration
nix run github:yourusername/nixCats-fish

# Or try minimal configuration  
nix run github:yourusername/nixCats-fish#minimalFish

# Or development configuration with live editing
nix run github:yourusername/nixCats-fish#devFish
```

### Using in Your Config

Add to your flake inputs:
```nix
inputs.nixCats-fish.url = "github:yourusername/nixCats-fish";
```

Then in your configuration:
```nix
# Direct package usage
home.packages = [ inputs.nixCats-fish.packages.${system}.fishCats ];

# Or via Home Manager module (future)
programs.nixCats-fish = {
  enable = true;
  packageName = "fishCats";  # or "minimalFish" or "devFish"
};
```

## 🏗️ Architecture

### Category Definitions
```nix
categoryDefinitions = { pkgs, settings, categories, extra, name, ... }: {
  runtimeDeps = {
    general = with pkgs; [ fish ];
    modern.core = with pkgs; [ eza bat fd ripgrep ];
    modern.extended = with pkgs; [ dust procs bottom ];
    fzf = with pkgs; [ fzf ];
    navigation = with pkgs; [ zoxide broot ];
    development = with pkgs; [ git direnv jq ];
  };
};
```

### Package Definitions  
```nix
packageDefinitions = {
  fishCats = { pkgs, name, ... }: {
    settings = {
      wrapRc = true;
      configDirName = "nixCats-fish";
    };
    categories = {
      general = true;
      modern = true;  # Enables all modern subcategories
      fzf = true;
      navigation = true;
      development = true;
    };
    extra = {
      theme = "tokyonight-night";
      editor = "nvim";
    };
  };
};
```

### Fish Configuration
```fish
# config.fish - Uses category system
if fishCats modern.core
    alias ls eza
    alias cat bat
end

if fishCats development  
    alias gs "git status"
    alias gc "git commit"
end

# Get theme from extra config
set -l theme (fishCats --get theme)
```

## 📁 Directory Structure

```
flakes/nixCats-fish/
├── flake.nix                    # Main flake with category system
├── README.md                    # This file
└── config/
    ├── config.fish             # Main configuration with category logic
    ├── conf.d/
    │   └── fzf.fish           # Category-specific config (fzf)
    └── functions/
        ├── fish_prompt.fish    # Theme-aware prompt
        └── fish_right_prompt.fish  # Right-side prompt
```

## 🎛️ Configuration Examples

### Check Categories in Fish
```fish
# Check if category is enabled
if fishCats fzf
    echo "FZF is available!"
end

# Check subcategories
if fishCats modern.core
    alias ls eza
end

# List all enabled categories
fishCats --list

# Get configuration values
set -l theme (fishCats --get theme)
set -l editor (fishCats --get editor)
```

### Custom Package Definition
```nix
myCustomFish = { pkgs, name, ... }: {
  settings = {
    wrapRc = false;  # Live configuration
    configDirName = "my-fish";
    unwrappedCfgPath = "/path/to/my/config";
  };
  
  categories = {
    general = true;
    fzf = true;
    # Only enable core modern tools, not extended
    modern.core = true;
  };
  
  extra = {
    theme = "catppuccin-mocha";
    customSetting = "my-value";
  };
};
```

## 🔧 Available Categories

- **`general`** - Core Fish shell
- **`modern.core`** - Essential modern CLI tools (eza, bat, fd, rg)
- **`modern.extended`** - Additional modern tools (dust, procs, bottom)
- **`fzf`** - Fuzzy finder with Fish integration
- **`navigation`** - Smart directory navigation (zoxide, broot)  
- **`development`** - Development tools (git, direnv, jq)
- **`utilities`** - Shell utilities (tealdeer, nix-tree)
- **`wsl`** - WSL-specific tools

## 🎨 Themes

- `tokyonight-night` - Dark theme with Tokyo Night colors
- `catppuccin-mocha` - Dark theme with Catppuccin colors  
- `default` - Fish default colors

## 🔑 Key Bindings (FZF)

- `Ctrl+R` - History search
- `Ctrl+T` - File search
- `Alt+C` - Directory search  
- `Ctrl+G` - Git files search

## 🤝 Comparison with nixCats-nvim

| Feature | nixCats-nvim | nixCats-fish |
|---------|--------------|--------------|
| Category System | ✅ | ✅ |
| Multiple Packages | ✅ | ✅ |
| Wrapped/Unwrapped | ✅ | ✅ |
| Runtime Querying | `nixCats('category')` | `fishCats category` |
| Live Configuration | ✅ | ✅ |
| Theme Integration | ✅ | ✅ |

## 📚 Learn More

This project is directly inspired by the excellent [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim). Check out their documentation to understand the underlying philosophy and architecture patterns that nixCats-fish inherits.

## 🧪 Development

```bash
# Clone and try
git clone <your-repo>
cd nixCats-fish

# Try different packages
nix run .#fishCats       # Full configuration
nix run .#minimalFish    # Minimal
nix run .#devFish        # Development with live config

# Development shell
nix develop
```