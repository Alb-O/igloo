{ pkgs }:
let
  popup = pkgs.writeShellScriptBin "tmux-fzf-popup" ''
    set -euo pipefail
    export FZF_DEFAULT_OPTS=${pkgs.lib.strings.escapeShellArg ""}
    if [ -n "''${TMUX:-}" ]; then
      exec ${pkgs.fzf}/bin/fzf-tmux -p 85%,85% --border --info=inline "$@"
    else
      exec ${pkgs.fzf}/bin/fzf --height=85% --layout=reverse --border --info=inline "$@"
    fi
  '';

  appLauncher = pkgs.writeShellScriptBin "tmux-app-launcher" ''
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

    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      printf '%s\n' "No graphical session detected." | ${popup}/bin/tmux-fzf-popup --prompt='Apps: ' || true
      exit 0
    fi

    list_data_dirs() {
      ''${COREUTILS}/printf '%s\n' "''${XDG_DATA_HOME:-$HOME/.local/share}"
      if [ -n "''${XDG_DATA_DIRS:-}" ]; then
        IFS=: read -r -a DIRS <<< "''${XDG_DATA_DIRS}"
        for d in "''${DIRS[@]}"; do [ -n "$d" ] && ''${COREUTILS}/printf '%s\n' "$d"; done
      fi
      for extra in \
        "/nix/var/nix/profiles/per-user/$USER/profile/share" \
        "/usr/local/share" \
        "/usr/share"; do [ -d "$extra" ] && ''${COREUTILS}/printf '%s\n' "$extra"; done
      [ -d "/etc/profiles/per-user/$USER/share" ] && ''${COREUTILS}/printf '%s\n' "/etc/profiles/per-user/$USER/share"
      [ -d "/run/current-system/sw/share" ] && ''${COREUTILS}/printf '%s\n' "/run/current-system/sw/share"
      if [ -n "''${XDG_STATE_HOME:-}" ] && [ -d "$XDG_STATE_HOME/nix/profile/share" ]; then
        ''${COREUTILS}/printf '%s\n' "$XDG_STATE_HOME/nix/profile/share"
      fi
      [ -d "$HOME/.nix-profile/share" ] && ''${COREUTILS}/printf '%s\n' "$HOME/.nix-profile/share"
    }

    list_desktop_files() {
      list_data_dirs | while IFS= read -r d; do
        if [ -d "$d/applications" ]; then
          if [ -x "''${FD}" ]; then
            "''${FD}" -L -t f -e desktop . "$d/applications"
          else
            "''${FIND}" -L "$d/applications" -type f -name '*.desktop'
          fi
        fi
      done | ''${AWK} '
        BEGIN { FS="/" }
        { path=$0; n=split($0, parts, "/"); base=parts[n]; sub(/\.desktop$/, "", base); if (!seen[base]++) { print path } }
      ' || true
    }

    build_menu() {
      list_desktop_files | while IFS= read -r file; do
        if "''${GREP}" -Ei -q '^[[:space:]]*Hidden[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi
        if "''${GREP}" -Ei -q '^[[:space:]]*NoDisplay[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi
        if "''${GREP}" -Ei -q '^[[:space:]]*Terminal[[:space:]]*=[[:space:]]*true([[:space:]]|$)' "$file"; then continue; fi
        name=$("''${GREP}" -m1 '^Name=' "$file" | "''${CUT}" -d'=' -f2- || true)
        if [ -z "''${name}" ]; then id=$(''${COREUTILS}/basename "$file"); name=''${id%%.desktop}; fi
        id=$(''${COREUTILS}/basename "$file"); id=''${id%%.desktop}
        ''${COREUTILS}/printf '%-64.64s\t%-40.40s\t%s\n' "$name" "$id" "$file"
      done | "''${SORT}" -t $'\t' -k1,1 -f
    }

    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-apps"
    CACHE_FILE="$CACHE_DIR/menu.tsv"
    CACHE_TTL="''${TMUX_APPS_CACHE_TTL:-300}"
    mkdir -p "$CACHE_DIR"
    now=$(''${DATE} +%s)
    last=0
    if [ -f "$CACHE_FILE" ]; then last=$(''${STAT} -c %Y "$CACHE_FILE" 2>/dev/null || echo 0); fi
    age=$(( now - last ))
    if [ ! -s "$CACHE_FILE" ] || [ "$age" -ge "$CACHE_TTL" ]; then
      tmp=$(mktemp "$CACHE_DIR/menu.XXXXXX"); build_menu >"$tmp" && mv "$tmp" "$CACHE_FILE"
    fi

    selection=$(cat "$CACHE_FILE" | ${popup}/bin/tmux-fzf-popup --prompt='Apps: ' --with-nth=1,2 --delimiter=$'\t' --ansi) || true
    [ -z "''${selection:-}" ] && exit 0
    file_path=$(echo "''${selection}" | "''${CUT}" -f3)
    "''${SETSID}" -f "''${DEX}" "''${file_path}" >/dev/null 2>&1 &
  '';

  cliphist = pkgs.writeShellScriptBin "tmux-cliphist" ''
    set -euo pipefail
    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      printf '%s\n' "No graphical session detected." | ${popup}/bin/tmux-fzf-popup --prompt='Clipboard: ' || true
      exit 0
    fi
    selection=$(cliphist list | ${popup}/bin/tmux-fzf-popup --prompt='Clipboard: ' --with-nth=2..)
    if [[ -n "$selection" ]]; then
      echo "$selection" | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
  '';

  unicode = pkgs.writeShellScriptBin "tmux-unicode" ''
    set -euo pipefail
    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      printf '%s\n' "No graphical session detected." | ${popup}/bin/tmux-fzf-popup --prompt='Unicode: ' || true
      exit 0
    fi
    selection=$(unipicker --command "${popup}/bin/tmux-fzf-popup --prompt='Unicode: '")
    if [[ -n "$selection" ]]; then
      echo "$selection" | ${pkgs.wl-clipboard}/bin/wl-copy -n
    fi
  '';

  systemMenu = pkgs.writeShellScriptBin "tmux-system-menu" ''
    set -euo pipefail
    if [ -n "''${WAYLAND_DISPLAY:-}" ] || [ -n "''${DISPLAY:-}" ]; then
      options="Lock\nSuspend\nRestart\nShutdown\nHibernate\nPower off monitors"
    else
      options="Suspend\nRestart\nShutdown\nHibernate"
    fi
    selection=$(echo "$options" | ${popup}/bin/tmux-fzf-popup --prompt='System: ')
    case "$selection" in
      "Lock") ${pkgs.swaylock}/bin/swaylock ;;
      "Suspend") systemctl suspend ;;
      "Restart") systemctl reboot ;;
      "Shutdown") systemctl poweroff ;;
      "Hibernate") systemctl hibernate ;;
      "Power off monitors") ${pkgs.niri}/bin/niri msg action power-off-monitors ;;
    esac
  '';
in
pkgs.symlinkJoin {
  name = "tmux-fzf-tools";
  paths = [ popup appLauncher cliphist unicode systemMenu ];
}

