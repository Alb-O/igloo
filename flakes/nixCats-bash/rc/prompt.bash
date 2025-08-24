# nixCats-bash prompt configuration
# This file is sourced by rc/init.bash after ble.sh and (optional) theme.

# Show last command's exit status if non-zero
__ncb_last_status() { local ec=$?; [ $ec -ne 0 ] && printf "[%d] " "$ec"; }

# Git branch (lightweight; falls back silently outside repos)
__ncb_git_branch() {
  command -v git >/dev/null 2>&1 || return 0
  local b
  b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 0
  [ -n "$b" ] && printf "[%s] " "$b"
}

# Compose PS1. Use classic escapes; ble.sh will process/optimize.
# Two-line prompt: user@host:cwd [branch]\n$ 
_PS1='\u@\h:\w '"\$(__ncb_git_branch)"'\n$ '

if [ -n "${BLE_VERSION:-}" ]; then
  # Apply via ble options
  bleopt prompt_ps1_final="$_PS1"
  # Optional right prompt (time). Uncomment to enable.
  # bleopt prompt_rps1='\t'
  ble/prompt/update
else
  # Fallback for plain bash
  PS1="$_PS1"
fi

unset _PS1
