# nixCats-bash user-editable bootstrap rc

# XDG defaults (for state/cache only)
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

_NCB_APP=nixCats-bash
# Resolve the directory of this rc file; configs live next to it
_NCB_CFG_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
_NCB_STATE_DIR="$XDG_STATE_HOME/$_NCB_APP"
_NCB_CACHE_DIR="$XDG_CACHE_HOME/$_NCB_APP"

mkdir -p "$_NCB_STATE_DIR" "$_NCB_CACHE_DIR"

#
# Sane Bash defaults
#
shopt -s histappend checkwinsize cmdhist
shopt -s extglob globstar dirspell cdspell
# opt-in: case-insensitive globbing; comment if you prefer case-sensitive
# shopt -s nocaseglob

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=${HISTSIZE:-50000}
HISTFILESIZE=${HISTFILESIZE:-100000}
HISTFILE=${HISTFILE:-"$XDG_STATE_HOME/bash/history"}
mkdir -p "$(dirname -- "$HISTFILE")"; : > "${HISTFILE}" 2>/dev/null || true

# XDG-friendly misc
export INPUTRC=${INPUTRC:-"$XDG_CONFIG_HOME/readline/inputrc"}

#
# Core helpers (fzf, completion, direnv, zoxide) — only if available
#
__ncb_try_source() { [ -r "$1" ] && . "$1"; }

# bash-completion
__ncb_try_source "/etc/bash_completion" || __ncb_try_source "/run/current-system/sw/etc/bash_completion"

# fzf integration (completion + keybindings)
if command -v fzf-share >/dev/null 2>&1; then
  _ncb_fzf_share="$(fzf-share 2>/dev/null)"
elif [ -n "${NIXCATS_FZF_SHARE:-}" ] && [ -d "$NIXCATS_FZF_SHARE" ]; then
  _ncb_fzf_share="$NIXCATS_FZF_SHARE"
fi
[ -n "${_ncb_fzf_share:-}" ] && __ncb_try_source "$_ncb_fzf_share/completion.bash"
[ -n "${_ncb_fzf_share:-}" ] && __ncb_try_source "$_ncb_fzf_share/key-bindings.bash"

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi

#
# ble.sh (Bash Line Editor)
#
if [ -n "${NIXCATS_BLESH_DIR:-}" ] && [ -r "$NIXCATS_BLESH_DIR/ble.sh" ]; then
  # Cache for ble.sh under XDG paths
  export BLE_CACHE_DIR="$_NCB_CACHE_DIR/blesh"
  mkdir -p "$BLE_CACHE_DIR"
  # Attach at first prompt (explicit; default is also prompt)
  . "$NIXCATS_BLESH_DIR/ble.sh" --attach=prompt
  
  # User ble.sh config hooks (safe to edit in repo) - MUST come first
  [ -r "$_NCB_CFG_DIR/blesh.init.bash" ] && . "$_NCB_CFG_DIR/blesh.init.bash"
  
  # Optional theme (env: NIXCATS_BASH_THEME=catppuccin-mocha|onedark|...) - AFTER blesh init
  if [ -n "${NIXCATS_BASH_THEME:-}" ] && [ -r "$_NCB_CFG_DIR/themes/${NIXCATS_BASH_THEME}.bash" ]; then
    . "$_NCB_CFG_DIR/themes/${NIXCATS_BASH_THEME}.bash"
  fi
  
  # Prompt setup (after ble.sh and theme)
  [ -r "$_NCB_CFG_DIR/prompt.bash" ] && . "$_NCB_CFG_DIR/prompt.bash"
fi

#
# Load user drop-ins (safe to edit)
#
if [ -d "$_NCB_CFG_DIR/bashrc.d" ]; then
  for f in "$_NCB_CFG_DIR"/bashrc.d/*.bash; do
    [ -f "$f" ] && . "$f"
  done
fi

#
# Prompt defaults (fallback if ble.sh did not set one)
#
if [ -z "$PS1" ]; then
  # non-interactive shell — nothing else to do
  return 0 2>/dev/null || exit 0
fi

if [ -z "$BLE_VERSION" ]; then
  # Simple, informative PS1 with git branch
  __ncb_git_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
  PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]$(b=$( __ncb_git_branch ); [ -n "$b" ] && printf " [\e[33m%s\e[0m]" "$b")\n$ '
fi
