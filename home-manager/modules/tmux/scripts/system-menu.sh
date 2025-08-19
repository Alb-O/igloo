#!/usr/bin/env bash
set -euo pipefail

# System menu using fzf
options="Lock
Suspend
Restart
Shutdown
Hibernate
Power off monitors"

if [[ -n "${TMUX:-}" ]]; then
    # Inside tmux - use fzf-tmux
    selection=$(echo "$options" | fzf-tmux -p --prompt='System: ')
else
    # Outside tmux - use regular fzf
    selection=$(echo "$options" | fzf --prompt='System: ')
fi

case "$selection" in
    "Lock") swaylock ;;
    "Suspend") systemctl suspend ;;
    "Restart") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
    "Hibernate") systemctl hibernate ;;
    "Power off monitors") niri msg action power-off-monitors ;;
esac