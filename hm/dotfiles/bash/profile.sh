# XDG-friendly interactive profile fragment sourced by programs.bash.profileExtra

# Source system profile if present (NixOS sets this)
if [ -e /etc/profile ]; then
  # shellcheck disable=SC1091
  . /etc/profile
fi

source_profiled_dir() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  # shellcheck disable=SC2045
  for f in $(LC_ALL=C ls -1 "$dir"/*.sh 2>/dev/null); do
    [ -r "$f" ] || continue
    # shellcheck disable=SC1090
    . "$f"
  done
}

# Prefer canonical per-user profile locations
if [ -d "/etc/profiles/per-user/$USER/etc/profile.d" ]; then
  source_profiled_dir "/etc/profiles/per-user/$USER/etc/profile.d"
elif [ -n "${XDG_STATE_HOME:-}" ] && [ -d "$XDG_STATE_HOME/nix/profile/etc/profile.d" ]; then
  source_profiled_dir "$XDG_STATE_HOME/nix/profile/etc/profile.d"
elif [ -d "$HOME/.local/state/nix/profile/etc/profile.d" ]; then
  source_profiled_dir "$HOME/.local/state/nix/profile/etc/profile.d"
fi

export HISTCONTROL="ignoreboth:erasedups"

ensure_runtime_dir() {
  if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
  fi
  if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="$HOME/.xdg-runtime"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
  fi
}
ensure_runtime_dir

if [ -n "${HISTFILE:-}" ]; then
  mkdir -p "$(dirname -- "$HISTFILE")"
  [ -e "$HISTFILE" ] || : > "$HISTFILE"
fi

if case $- in *i*) true ;; *) false ;; esac; then
  eval "$(direnv hook bash)"
  eval "$(zoxide init bash --cmd cd)"
  alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
  if command -v fish >/dev/null 2>&1 && [ "$0" != "fish" ] && [ -z "${FISH_VERSION:-}" ]; then
    exec fish
  fi
fi
