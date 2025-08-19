#!/usr/bin/env bash
set -euo pipefail

# App launcher using fzf-tmux
app=$(tmux run-shell "compgen -c | sort -u | fzf-tmux -p --prompt='Launch: '")
if [[ -n "$app" ]]; then
    exec "$app"
fi