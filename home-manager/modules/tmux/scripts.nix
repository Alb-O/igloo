# Tmux fzf picker scripts
{ pkgs, ... }:

rec {
  # Consistent fzf popup wrapper (tmux-aware)
  fzfPopupCmd = pkgs.writeShellScript "tmux-fzf-popup" ''
    set -euo pipefail
    # Neutralize global defaults to keep menus consistent
    export FZF_DEFAULT_OPTS=
    if [ -n "''${TMUX:-}" ]; then
      exec "${pkgs.fzf}/bin/fzf-tmux" -p 85%,85% --border --info=inline "$@"
    else
      exec "${pkgs.fzf}/bin/fzf" --height=85% --layout=reverse --border --info=inline "$@"
    fi
  '';
  # App launcher - fzf-based GUI app picker
  appLauncher = pkgs.writeShellScript "tmux-app-launcher" ''
    # Robust fzf-tmux app launcher for graphical desktop entries.
    set -euo pipefail

    COREUTILS=${pkgs.coreutils}/bin
    DATE=${pkgs.coreutils}/bin/date
    STAT=${pkgs.coreutils}/bin/stat
    FIND=${pkgs.findutils}/bin/find
    FD=${pkgs.fd}/bin/fd
    GREP=${pkgs.gnugrep}/bin/grep
    SED=${pkgs.gnused}/bin/sed
    AWK=${pkgs.gawk}/bin/awk
    SORT=${pkgs.coreutils}/bin/sort
    CUT=${pkgs.coreutils}/bin/cut
    DEX=${pkgs.dex}/bin/dex
    SETSID=${pkgs.util-linux}/bin/setsid

    # Detect graphical session; if absent, bail early with a friendly message.
    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      ''${COREUTILS}/printf '%s\n' "No graphical session detected." | "${fzfPopupCmd}" --prompt='Apps: ' || true
      exit 0
    fi

    list_data_dirs() {
      # Print candidate XDG data roots (share dirs) one per line.
      # Include standard XDG vars and common NixOS locations explicitly.
      ''${COREUTILS}/printf '%s\n' "''${XDG_DATA_HOME:-$HOME/.local/share}"

      if [ -n "''${XDG_DATA_DIRS:-}" ]; then
        IFS=: read -r -a DIRS <<< "''${XDG_DATA_DIRS}"
        for d in "''${DIRS[@]}"; do
          [ -n "$d" ] && ''${COREUTILS}/printf '%s\n' "$d"
        done
      fi

      # Conservative additional fallbacks (printed only if they exist)
      for extra in \
        "/nix/var/nix/profiles/per-user/$USER/profile/share" \
        "/usr/local/share" \
        "/usr/share"; do
        [ -d "$extra" ] && ''${COREUTILS}/printf '%s\n' "$extra"
      done

      # NixOS canonical per-user profile (NixOS sets this in XDG_DATA_DIRS, but be explicit)
      [ -d "/etc/profiles/per-user/$USER/share" ] && ''${COREUTILS}/printf '%s\n' "/etc/profiles/per-user/$USER/share"
      # Current system profile
      [ -d "/run/current-system/sw/share" ] && ''${COREUTILS}/printf '%s\n' "/run/current-system/sw/share"
      # Home Manager XDG STATE user profile (when use-xdg-base-directories is enabled)
      if [ -n "''${XDG_STATE_HOME:-}" ] && [ -d "$XDG_STATE_HOME/nix/profile/share" ]; then
        ''${COREUTILS}/printf '%s\n' "$XDG_STATE_HOME/nix/profile/share"
      fi
      # Legacy user profile fallback (discouraged, but may exist)
      [ -d "$HOME/.nix-profile/share" ] && ''${COREUTILS}/printf '%s\n' "$HOME/.nix-profile/share"
    }

    list_desktop_files() {
      # Deduplicate by desktop-id (basename without .desktop) while preserving precedence order.
      # Print: <path-to-desktop>
      list_data_dirs | while IFS= read -r d; do
        if [ -d "$d/applications" ]; then
          # Use fd for speed; fall back to find if needed
          if [ -x "''${FD}" ]; then
            "''${FD}" -L -t f -e desktop . "$d/applications"
          else
            "''${FIND}" -L "$d/applications" -type f -name '*.desktop'
          fi
        fi
      done |
      ''${AWK} '
        BEGIN { FS="/" }
        {
          path=$0
          n=split($0, parts, "/"); base=parts[n]
          sub(/\.desktop$/, "", base)
          if (!seen[base]++) { print path }
        }
      ' || true
    }

    # Build menu entries: "Name[TAB]DesktopID[TAB]Path"
    build_menu() {
      list_desktop_files | while IFS= read -r file; do
        # Skip Hidden or NoDisplay entries and terminal-only apps.
        if "''${GREP}" -Ei -q '^[[:space:]]*Hidden[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi
        if "''${GREP}" -Ei -q '^[[:space:]]*NoDisplay[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi
        if "''${GREP}" -Ei -q '^[[:space:]]*Terminal[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi

        name=$("''${GREP}" -m1 '^Name=' "$file" | "''${CUT}" -d'=' -f2- || true)
        if [ -z "''${name}" ]; then
          # Fall back to desktop id
          id=$(''${COREUTILS}/basename "$file")
          name=''${id%%.desktop}
        fi

        id=$(''${COREUTILS}/basename "$file")
        id=''${id%%.desktop}
        # Prefer Name; append id for disambiguation
        # Left-justify and pad columns for better readability in fzf
        # Name: 64 chars, ID: 40 chars
        ''${COREUTILS}/printf '%-64.64s\t%-40.40s\t%s\n' "$name" "$id" "$file"
      done | "''${SORT}" -t $'\t' -k1,1 -f
    }

    # Cache menu to speed up repeated launches
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-apps"
    CACHE_FILE="$CACHE_DIR/menu.tsv"
    CACHE_TTL="''${TMUX_APPS_CACHE_TTL:-300}"

    ensure_cache() {
      mkdir -p "$CACHE_DIR"
      now=$(''${DATE} +%s)
      last=0
      if [ -f "$CACHE_FILE" ]; then
        last=$(''${STAT} -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
      fi
      age=$(( now - last ))
      if [ ! -s "$CACHE_FILE" ] || [ "$age" -ge "$CACHE_TTL" ]; then
        tmp=$(mktemp "$CACHE_DIR/menu.XXXXXX")
        build_menu >"$tmp" && mv "$tmp" "$CACHE_FILE"
      fi
    }

    ensure_cache
    selection=$(cat "$CACHE_FILE" | "${fzfPopupCmd}" --prompt='Apps: ' --with-nth=1,2 --delimiter=$'\t' --ansi) || true
    if [ -z "''${selection:-}" ]; then
      exit 0
    fi

    # Extract path field (3rd column)
    file_path=$(echo "''${selection}" | "''${CUT}" -f3)

    # Launch via dex and detach from tmux/tty; suppress all output.
    # dex interprets Exec= properly, including field codes and quoting.
    "''${SETSID}" -f "''${DEX}" "''${file_path}" >/dev/null 2>&1 &
  '';

  cliphistPicker = pkgs.writeShellScript "tmux-cliphist-picker" ''
    selection=$(cliphist list | "${fzfPopupCmd}" --prompt='Clipboard: ' --with-nth=2..)
    if [[ -n "$selection" ]]; then
      echo "$selection" | cliphist decode | wl-copy
    fi
  '';

  unicodePicker = pkgs.writeShellScript "tmux-unicode-picker" ''
    selection=$(unipicker --command "${fzfPopupCmd} --prompt='Unicode: '")
    if [[ -n "$selection" ]]; then
      echo "$selection" | wl-copy -n
    fi
  '';

  systemMenu = pkgs.writeShellScript "tmux-system-menu" ''
    options="Lock
Suspend  
Restart
Shutdown
Hibernate
Power off monitors"
    selection=$(echo "$options" | "${fzfPopupCmd}" --prompt='System: ')
    case "$selection" in
      "Lock") swaylock ;;
      "Suspend") systemctl suspend ;;
      "Restart") systemctl reboot ;;
      "Shutdown") systemctl poweroff ;;
      "Hibernate") systemctl hibernate ;;
      "Power off monitors") niri msg action power-off-monitors ;;
    esac
  '';
}
