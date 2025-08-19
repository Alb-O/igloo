#!/usr/bin/env bash
set -euo pipefail

# System menu using fzf-tmux
selection=$(tmux run-shell "echo 'Lock
Suspend
Restart
Shutdown
Hibernate
Power off monitors' | fzf-tmux -p --prompt='System: '")

case "$selection" in
    "Lock") swaylock ;;
    "Suspend") systemctl suspend ;;
    "Restart") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
    "Hibernate") systemctl hibernate ;;
    "Power off monitors") niri msg action power-off-monitors ;;
esac