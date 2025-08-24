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

# Compose PS1
# - For ble.sh sessions, avoid command substitutions inside PS1 and use
#   contrib sequences (safer rendering, fewer redraw artifacts).
# - For plain Bash fallback, use a simple prompt without VCS info.

if [ -n "${BLE_VERSION:-}" ]; then
  # Left prompt: user@host:cwd and git branch via contrib sequence
  # No right prompt by default (see NIXCATS_BASH_RPROMPT in blesh.init.bash)
  PS1='\u@\h:\w \q{contrib/git-branch}\n$ '
  bleopt prompt_rps1=
  ble/prompt/update
else
  # Plain bash: keep it simple (no $(...) to avoid redraw issues)
  PS1='\u@\h:\w\n$ '
fi
