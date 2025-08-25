# nixCats-fish

An opinionated, nix-native way to manage a modern Fish shell environment with the same architecture principles as nixCats-nvim:

- Nix handles meta concerns: fetch, pin, compose, and wrap tools.
- Day-to-day shell customization lives as editable scripts under XDG config — no Nix rebuilds for tweaking your shell.
- Clean separation between immutable toolchain and mutable user config.

## Goals

- Fast, modern Fish shell with sane defaults.
- Excellent fzf integration with vi keybindings.
- XDG-first layout: `~/.config/nixCats-fish`, `~/.local/state/nixCats-fish`, `~/.cache/nixCats-fish`.
- No-rebuild config: edit Fish files, restart shell.
- Optional Home Manager/NixOS modules to install and (optionally) set shell.

## Config Resolution

At runtime, `fishcat` resolves your config in this order:

1) `NIXCATS_FISH_DIR/config.fish` if the env var is set. This is the preferred, nixCats-style workflow: point it at your repo directory so you can edit scripts live without rebuilds.
2) `$XDG_CONFIG_HOME/nixCats-fish/config.fish` if you maintain a user config outside the repo.
3) Built-in default config from the Nix store (read-only fallback).

Recommended setup (live-edit in this repo):

- Set an env var, e.g. in your `.env` used by this repo: `NIXCATS_FISH_DIR=/home/you/dev/igloo/flakes/nixCats-fish/config`
- Then `fishcat` will source `config/config.fish`, which loads:
  - `config/conf.d/fzf.fish` for fzf integration
  - `config/functions/fish_prompt.fish` for prompt configuration
  - Any other `config/conf.d/*.fish` snippets

## Package

The package exposes an executable `fishcat` which launches Fish with our configuration. It puts the following tools on PATH:

- `fish` — the Fish shell
- `fzf` — fuzzy finder with key bindings
- `direnv` — directory-based environment management
- `zoxide` — smart cd replacement
- `fd`, `ripgrep`, `bat`, `eza` — modern CLI tools

## Features

- **Vi keybindings** by default (easily changeable to emacs mode)
- **FZF integration** with:
  - `Ctrl+R`: History search
  - `Ctrl+T`: File search
  - `Alt+C`: Directory search
  - `Ctrl+G`: Git file search
- **Modern aliases**: `ls` → `eza`, `cat` → `bat`, `grep` → `rg`, `find` → `fd`
- **Git-aware prompt** with branch display
- **SSH-aware prompt** shows hostname when connected remotely
- **XDG compliance** for all state and cache files

## Editing Your Shell

Edit files under your repo `flakes/nixCats-fish/config` (or wherever `NIXCATS_FISH_DIR` points). Examples:

- Change prompt: edit `functions/fish_prompt.fish`
- Add keybindings: create `conf.d/keybindings.fish`
- Customize fzf: edit `conf.d/fzf.fish`
- Toggle vi/emacs mode: change `fish_key_bindings` in `config.fish`

No rebuild/switch needed — open a new shell or run `fishcat`.

## Installation

Add to your flake inputs:

```nix
inputs.nixCats-fish.url = "path:./flakes/nixCats-fish";
```

Then use in Home Manager:

```nix
programs.nixCats-fish = {
  enable = true;
  setAsDefaultShell = true;  # Optional
  seedConfig = true;         # Seeds config template on first run
};
```