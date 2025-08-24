# nixCats-bash

An opinionated, nix-native way to manage a modern Bash/ble.sh environment with the same architecture principles as nixCats-nvim:

- Nix handles meta concerns: fetch, pin, compose, and wrap tools.
- Day-to-day shell customization lives as editable scripts under XDG config/state — no Nix rebuilds for tweaking your shell.
- Clean separation between immutable toolchain and mutable user config.

## Goals

- Fast, robust interactive Bash with [ble.sh] enabled by default.
- Sane defaults (history, completion, prompt, fzf integration, direnv/zoxide hooks).
- XDG-first layout: `~/.config/nixCats-bash`, `~/.local/state/nixCats-bash`, `~/.cache/nixCats-bash`.
- No-rebuild config: edit Bash files, restart shell.
- Optional Home Manager/NixOS modules to install and (optionally) set shell.

## Config Resolution

At runtime, `bashcat` resolves your config in this order:

1) `NIXCATS_BASH_DIR/init.bash` if the env var is set. This is the preferred, nixCats-style workflow: point it at your repo directory so you can edit scripts live without rebuilds.
2) `$XDG_CONFIG_HOME/nixCats-bash/init.bash` if you maintain a user config outside the repo.
3) Built-in default init from the Nix store (read-only fallback).

Recommended setup (live-edit in this repo):

- Set an env var, e.g. in your `.env` used by this repo: `NIXCATS_BASH_DIR=/home/you/dev/igloo/flakes/nixCats-bash/rc`
- Then `bashcat` will source `rc/init.bash`, which sources:
  - `rc/blesh.init.bash` for ble.sh tweaks
  - Optional theme `rc/themes/${NIXCATS_BASH_THEME}.bash`
  - `rc/prompt.bash` for prompt configuration
  - Any `rc/bashrc.d/*.bash` snippets

## Package

The package exposes an executable `bashcat` which launches Bash with `--rcfile` pointing at a small wrapper rc that sources your editable config. It also puts the following tools on PATH (tunable via categories in flake):

- `blesh` (ble.sh) — available via `$NIXCATS_BLESH_DIR/ble.sh`
- `fzf` (+ its Bash bindings) — available via `$NIXCATS_FZF_SHARE`
- `bash-completion`, `direnv`, `zoxide`

## Modules

- Home Manager module (exported): install `bashcat` into user packages, optionally set it as login shell, and (optionally) pre-seed the config template.
- NixOS module (exported): mirrors HM options for system-wide install.

## Editing Your Shell

Edit files under your repo `flakes/nixCats-bash/rc` (or wherever `NIXCATS_BASH_DIR` points). Examples:

- Add a keybinding: create `rc/bashrc.d/10-keybinds.bash` and reload.
- Change prompt or ble.sh theme: edit `rc/blesh.init.bash`.
- Toggle fzf bindings: `rc/init.bash` auto-detects via `$NIXCATS_FZF_SHARE` or `fzf-share`.
- Pick a theme: set `NIXCATS_BASH_THEME=catppuccin-mocha` (or `onedark`) in your environment.

No rebuild/switch needed — open a new shell or `exec bashcat`.

[ble.sh]: https://github.com/akinomyoga/ble.sh
