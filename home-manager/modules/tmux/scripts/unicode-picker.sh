#!/usr/bin/env bash
set -euo pipefail

# Unicode picker using fzf
if [[ -n "${TMUX:-}" ]]; then
    # Inside tmux - use fzf-tmux
    selection=$(unipicker --command "fzf-tmux -p --prompt='Unicode: '")
else
    # Outside tmux - use regular fzf
    selection=$(unipicker --command "fzf --prompt='Unicode: '")
fi

if [[ -n "$selection" ]]; then
    echo "$selection" | wl-copy -n
fi