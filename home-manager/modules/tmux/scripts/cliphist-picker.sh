#!/usr/bin/env bash
set -euo pipefail

# Clipboard history picker using fzf-tmux
selection=$(tmux run-shell "cliphist list | fzf-tmux -p --prompt='Clipboard: ' --with-nth=2..")
if [[ -n "$selection" ]]; then
    echo "$selection" | cliphist decode | wl-copy
fi