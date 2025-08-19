#!/usr/bin/env bash
set -euo pipefail

# Clipboard history picker using fzf
if [[ -n "${TMUX:-}" ]]; then
    # Inside tmux - use fzf-tmux
    selection=$(cliphist list | fzf-tmux -p --prompt='Clipboard: ' --with-nth=2..)
else
    # Outside tmux - use regular fzf
    selection=$(cliphist list | fzf --prompt='Clipboard: ' --with-nth=2..)
fi

if [[ -n "$selection" ]]; then
    echo "$selection" | cliphist decode | wl-copy
fi