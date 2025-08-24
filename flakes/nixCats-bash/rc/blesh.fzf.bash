#!/usr/bin/env bash
# nixCats-bash: ble.sh-centric fzf integration
# - Uses ble/contrib modules to avoid conflicts with vanilla fzf init
# - Centralizes defaults, tmux handling, and optional git/menu integrations

# Only proceed when ble.sh is active
[[ -n ${BLE_VERSION-} ]] || return 0

# Resolve fzf base for contrib integration
# Prefer explicit NIXCATS_FZF_SHARE provided by wrapper; else try fzf-share helper
if [[ -z ${_ble_contrib_fzf_base-} ]]; then
  if [[ -n ${NIXCATS_FZF_SHARE-} && -d ${NIXCATS_FZF_SHARE} ]]; then
    _ble_contrib_fzf_base=${NIXCATS_FZF_SHARE}
  elif command -v fzf-share >/dev/null 2>&1; then
    _ble_contrib_fzf_base=$(fzf-share 2>/dev/null || true)
  fi
fi

# Sensible fzf defaults (safe to override via environment)
if [[ -z ${FZF_DEFAULT_OPTS-} ]]; then
  FZF_DEFAULT_OPTS=(
    --height=40%
    --layout=reverse
    --border
    --bind=ctrl-/:toggle-preview
  )
  # Preview integration: prefer file-preview, else bat, else head
  if command -v file-preview >/dev/null 2>&1; then
    FZF_DEFAULT_OPTS+=(--preview='file-preview {}')
  elif command -v bat >/dev/null 2>&1; then
    FZF_DEFAULT_OPTS+=(--preview='bat --style=numbers --color=always --line-range :400 {} 2>/dev/null || head -n 200 {} 2>/dev/null')
  else
    FZF_DEFAULT_OPTS+=(--preview='head -n 200 {} 2>/dev/null')
  fi
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS[*]}"
fi

# fzf in tmux panes by default
if [[ -n ${TMUX-} ]]; then
  : "${FZF_TMUX:=1}"
  : "${FZF_TMUX_OPTS:=-p 60%,70%}"
  export FZF_TMUX FZF_TMUX_OPTS
fi

# Feature toggles (env override allowed)
: "${NIXCATS_FZF_ENABLE:=1}"
: "${NIXCATS_FZF_COMPLETION:=1}"
: "${NIXCATS_FZF_KEYBINDINGS:=1}"
: "${NIXCATS_FZF_GIT:=1}"
: "${NIXCATS_FZF_MENU:=0}"

(( NIXCATS_FZF_ENABLE )) || return 0

# Load fzf completion and key bindings via ble-contrib
if (( NIXCATS_FZF_COMPLETION )); then
  ble-import -d contrib/integration/fzf-completion
fi
if (( NIXCATS_FZF_KEYBINDINGS )); then
  ble-import -d contrib/integration/fzf-key-bindings
fi

# Optional: fzf-git integration (C-g sequences, sabbrev, etc.)
if (( NIXCATS_FZF_GIT )); then
  : "${_ble_contrib_fzf_git_config:=key-binding}"
  ble-import -d contrib/integration/fzf-git
fi

# Optional: use fzf for menu completion
if (( NIXCATS_FZF_MENU )); then
  ble-import -d contrib/integration/fzf-menu
fi

