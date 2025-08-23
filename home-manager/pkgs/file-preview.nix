{pkgs}:
pkgs.writeShellScriptBin "file-preview" ''
  #!/usr/bin/env bash
  #
  # Generic file preview script that can handle text files, images, and directories.
  # Works with any terminal-based preview context.
  #
  # Dependencies:
  # - nvimpager (assumed to be available in PATH)
  # - https://github.com/hpjansson/chafa
  # - https://iterm2.com/utilities/imgcat

  if [[ $# -ne 1 ]]; then
    >&2 echo "usage: $0 FILENAME[:LINENO][:IGNORED]"
    exit 1
  fi

  file=''${1/#\~\//$HOME/}

  center=0
  if [[ ! -r $file ]]; then
    if [[ $file =~ ^(.+):([0-9]+)\ *$ ]] && [[ -r ''${BASH_REMATCH[1]} ]]; then
      file=''${BASH_REMATCH[1]}
      center=''${BASH_REMATCH[2]}
    elif [[ $file =~ ^(.+):([0-9]+):[0-9]+\ *$ ]] && [[ -r ''${BASH_REMATCH[1]} ]]; then
      file=''${BASH_REMATCH[1]}
      center=''${BASH_REMATCH[2]}
    fi
  fi

  # If the file is a directory, use broot for preview
  if [[ -d "$file" ]]; then
    ${pkgs.broot}/bin/broot -c :pt "$file"
    exit
  fi

  type=$(${pkgs.file}/bin/file --brief --dereference --mime -- "$file")

  if [[ ! $type =~ image/ ]]; then
    if [[ $type =~ =binary ]]; then
      ${pkgs.file}/bin/file "$1"
      exit
    fi

    if command -v nvimpager > /dev/null; then
      if [[ ''${center:-0} -gt 0 ]]; then
        nvimpager -c "+''${center}" -- "$file"
      else
        nvimpager -c -- "$file"
      fi
    else
      ${pkgs.coreutils}/bin/cat "$file"
    fi
    exit
  fi

  # Determine terminal dimensions
  # Try environment variables first (commonly set by preview tools)
  if [[ -n "''${PREVIEW_COLUMNS:-}" && -n "''${PREVIEW_LINES:-}" ]]; then
    dim=''${PREVIEW_COLUMNS}x''${PREVIEW_LINES}
  elif [[ -n "''${FZF_PREVIEW_COLUMNS:-}" && -n "''${FZF_PREVIEW_LINES:-}" ]]; then
    dim=''${FZF_PREVIEW_COLUMNS}x''${FZF_PREVIEW_LINES}
  else
    # Fallback to terminal size
    dim=$(${pkgs.coreutils}/bin/stty size < /dev/tty | ${pkgs.gawk}/bin/awk '{print $2 "x" $1}')
  fi

  # Handle edge cases for dimension calculation
  if [[ $dim = x ]]; then
    dim=$(${pkgs.coreutils}/bin/stty size < /dev/tty | ${pkgs.gawk}/bin/awk '{print $2 "x" $1}')
  elif ! [[ $KITTY_WINDOW_ID ]] && [[ -n "''${PREVIEW_TOP:-''${FZF_PREVIEW_TOP:-}}" && -n "''${PREVIEW_LINES:-''${FZF_PREVIEW_LINES:-}}" ]]; then
    preview_top=''${PREVIEW_TOP:-''${FZF_PREVIEW_TOP:-}}
    preview_lines=''${PREVIEW_LINES:-''${FZF_PREVIEW_LINES:-}}
    terminal_lines=$(${pkgs.coreutils}/bin/stty size < /dev/tty | ${pkgs.gawk}/bin/awk '{print $1}')
    if (( preview_top + preview_lines == terminal_lines )); then
      # Avoid scrolling issue when the Sixel image touches the bottom of the screen
      # * https://github.com/junegunn/fzf/issues/2544
      columns=''${PREVIEW_COLUMNS:-''${FZF_PREVIEW_COLUMNS:-}}
      dim=''${columns}x$((preview_lines - 1))
    fi
  fi

  # 1. Use icat (from Kitty) if kitten is installed
  if [[ $KITTY_WINDOW_ID ]] || [[ $GHOSTTY_RESOURCES_DIR ]] && command -v ${pkgs.kitty}/bin/kitten > /dev/null; then
    # 1. 'memory' is the fastest option but if you want the image to be scrollable,
    #    you have to use 'stream'.
    #
    # 2. The last line of the output is the ANSI reset code without newline.
    #    This confuses preview tools and makes them render scroll offset indicator.
    #    So we remove the last line and append the reset code to its previous line.
    ${pkgs.kitty}/bin/kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | ${pkgs.gnused}/bin/sed '$d' | ${pkgs.gnused}/bin/sed $'$s/$/\e[m/'

  # 2. Use chafa with Sixel output
  elif command -v ${pkgs.chafa}/bin/chafa > /dev/null; then
    ${pkgs.chafa}/bin/chafa -s "$dim" "$file"
    # Add a new line character so that preview tools can display multiple images in the preview window
    echo

  # 3. If chafa is not found but imgcat is available, use it on iTerm2
  elif command -v imgcat > /dev/null; then
    # NOTE: We should use https://iterm2.com/utilities/it2check to check if the
    # user is running iTerm2. But for the sake of simplicity, we just assume
    # that's the case here.
    imgcat -W "''${dim%%x*}" -H "''${dim##*x}" "$file"

  # 4. Cannot find any suitable method to preview the image
  else
    ${pkgs.file}/bin/file "$file"
  fi
''
