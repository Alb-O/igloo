#!/usr/bin/env bash
# nixCats-bash: simple fzf-powered pickers (no default bindings)
# - File picker to open in $EDITOR
# - Directory picker to cd
#
# Optional keybindings (requires ble.sh): set NIXCATS_FZF_PICKER_BIND=1
#   - C-x C-f -> pick file to edit
#   - C-x C-d -> pick directory to cd

# Determine a file lister (fd preferred)
_ncb_cmd_fd() {
  if command -v fd >/dev/null 2>&1; then
    fd --hidden --follow --exclude .git "$@"
  else
    # find fallback
    find . -path '*/.git' -prune -o -type f -print
  fi
}

_ncb_cmd_fddirs() {
  if command -v fd >/dev/null 2>&1; then
    fd --hidden --follow --exclude .git --type d "$@"
  else
    find . -path '*/.git' -prune -o -type d -print
  fi
}

# File picker: echoes selection or opens with $EDITOR if interactive
ncb_fzf_pick_file() {
  local sel
  sel=$(_ncb_cmd_fd | fzf --prompt='File> ' --preview 'bat --style=numbers --color=always --line-range :400 {} 2>/dev/null || head -n 200 {} 2>/dev/null' --preview-window=right:60%:wrap) || return 1
  printf '%s\n' "${sel}"
}

ncb_fzf_edit() {
  local f
  f=$(ncb_fzf_pick_file) || return 1
  : "${EDITOR:=vi}"
  "$EDITOR" -- "$f"
}

# Directory picker: cd to selected directory
ncb_fzf_cd() {
  local dir
  dir=$(_ncb_cmd_fddirs | fzf --prompt='Dir> ' --preview 'ls -la --color=always {} 2>/dev/null | sed -n "1,200p"') || return 1
  cd -- "$dir" || return 1
}

# Optional ble.sh keybindings
if [[ -n ${BLE_VERSION-} && ${NIXCATS_FZF_PICKER_BIND-0} -eq 1 ]]; then
  ble-bind -m emacs   -x 'C-x C-f' ncb_fzf_edit
  ble-bind -m vi_imap -x 'C-x C-f' ncb_fzf_edit
  ble-bind -m emacs   -x 'C-x C-d' ncb_fzf_cd
  ble-bind -m vi_imap -x 'C-x C-d' ncb_fzf_cd
fi

