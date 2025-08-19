#!/usr/bin/env bash
set -euo pipefail

# Unicode picker using fzf-tmux
selection=$(unipicker --command "tmux run-shell 'fzf-tmux -p --prompt=\"Unicode: \"'")
if [[ -n "$selection" ]]; then
    echo "$selection" | wl-copy -n
fi