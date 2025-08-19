#!/usr/bin/env bash
set -euo pipefail

# App launcher using fzf
if [[ -n "${TMUX:-}" ]]; then
    # Inside tmux - use fzf-tmux
    app=$(compgen -c | sort -u | fzf-tmux -p --prompt='Launch: ')
else
    # Outside tmux - spawn in a new terminal with tmux if available, otherwise use regular fzf
    if command -v tmux >/dev/null && tmux has-session 2>/dev/null; then
        app=$(tmux new-window -P -d "compgen -c | sort -u | fzf-tmux -p --prompt='Launch: ' && read" 2>/dev/null || compgen -c | sort -u | fzf --prompt='Launch: ')
    else
        app=$(compgen -c | sort -u | fzf --prompt='Launch: ')
    fi
fi

if [[ -n "$app" ]]; then
    exec "$app" &
fi