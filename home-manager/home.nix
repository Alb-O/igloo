# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  lib,
  inputs,
  globals,
  ...
}: let
  colors = import ./lib/themes globals;
in {
  # Import modular configuration
  imports = [
    # Custom modules
    (import ./modules {inherit inputs globals;})

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Enable tmux fzf-tools even in non-graphical environments
  igloo.tmux.pickers.enable = true;

  # Basic user information
  home = {
    username = globals.user.username;
    homeDirectory = globals.user.homeDirectory;
  };

  # User packages
  home.packages = with pkgs.unstable;
    [
      # CLI Tools (always included)
      jq
      fastfetch
      gh
      just
      unzip
      #opencode
      xdg-ninja
      lm_sensors
      ffmpeg
      yt-dlp
      ripgrep
      unison
      bat
      nb
      rucola
      tree
      imagemagick
      poppler-utils
      unipicker
      # prettier  # Temporarily disabled due to LICENSE file conflict with helix-gpt
      nodejs
      gcc
      bun
      typescript-language-server
      helix-gpt
    ]
    ++ lib.optionals globals.system.isGraphical [
      # Graphical Tools (only when isGraphical = true)
      hyprpicker
      foot
      hydrus
      vesktop
      # Clipboard tools for Wayland
      wl-clipboard
      cliphist
    ]
    ++ [
      # Custom packages
      (pkgs.writeShellApplication {
        name = "codex";
        runtimeInputs = [pkgs.nodejs];
        text = ''
          exec ${pkgs.nodejs}/bin/npx -y @openai/codex "$@"
        '';
      })
      pkgs.opencode-src
    ]
    ++ lib.optionals globals.system.isGraphical [
      # Custom graphical packages
      pkgs.blender-daily
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;

  # Environment variables from .env file (loaded during build)
  home.sessionVariables = {
    COPILOT_API_KEY = builtins.getEnv "COPILOT_API_KEY";
    COPILOT_MODEL = builtins.getEnv "COPILOT_MODEL";
    HANDLER = builtins.getEnv "HANDLER";
  };

  # Ensure login shells source Home Manager session vars from XDG-friendly paths
  # and avoid legacy ~/.nix-profile references.
  # Manage the user's login profile explicitly. Rationale:
  # - Home Manager's genericLinux target historically generated a ~/.profile that
  #   sourced ~/.nix-profile/etc/profile.d/hm-session-vars.sh. With
  #   nix.settings.use-xdg-base-directories = true, the canonical per-user
  #   profile lives under $XDG_STATE_HOME/nix/profile (or /etc/profiles/per-user on NixOS).
  # - We force our own .profile here so shells stop referencing ~/.nix-profile and
  #   instead prefer XDG locations, falling back safely when needed.
  # - On NixOS, /etc/profiles/per-user/$USER is the stable canonical path for
  #   hm-session-vars. We try that first, then XDG STATE paths.
  # - If a legacy ~/.nix-profile exists, remove it or symlink it to
  #   $XDG_STATE_HOME/nix/profile to avoid warnings.
  home.file.".profile" = lib.mkForce {
    text = ''
      # Source system profile if present (NixOS sets this)
      if [ -e /etc/profile ]; then
        . /etc/profile
      fi

      # Prefer canonical per-user profile under /etc (NixOS),
      # then XDG paths as configured by use-xdg-base-directories.
      #
      # Order of preference:
      #  1) /etc/profiles/per-user/$USER/...  (canonical on NixOS)
       #  2) "$XDG_STATE_HOME"/nix/profile/...  (XDG-compliant user profile)
       #  3) "$HOME/.local/state"/nix/profile/...       (implicit XDG_STATE_HOME)
       #
       # Notes:
       # - We intentionally do NOT use ~/.nix-profile to avoid legacy paths.
       # - If a tool still references ~/.nix-profile, create a compat symlink:
       #     ln -sTf "$\{XDG_STATE_HOME}:-$HOME/.local/state}/nix/profile" "$HOME/.nix-profile"
       if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
         . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
       elif [ -n "$XDG_STATE_HOME" ] && [ -e "$XDG_STATE_HOME/nix/profile/etc/profile.d/hm-session-vars.sh" ]; then
         . "$XDG_STATE_HOME/nix/profile/etc/profile.d/hm-session-vars.sh"
      elif [ -e "$HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.local/state/nix/profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Ensure XDG_RUNTIME_DIR exists for tools that expect it (e.g., ble.sh)
      if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
      fi
      if [ ! -d "$XDG_RUNTIME_DIR" ]; then
        # Fallback to a private dir if systemd runtime dir is unavailable (e.g., TTY/tmux)
        export XDG_RUNTIME_DIR="$HOME/.xdg-runtime"
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
      fi

       # Ensure Bash history path under XDG state exists to avoid errors
       if [ -n "''${HISTFILE:-}" ]; then
         mkdir -p "$(dirname -- "''${HISTFILE}")"
         [ -e "''${HISTFILE}" ] || : > "''${HISTFILE}"
       fi

       # Add Windows PATH for WSL interoperability
       if [ "''${IS_WSL:-}" = "true" ]; then
         WIN_PATHS="/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
         # Check if PowerShell 7 is installed
         if [ -d "/mnt/c/Program Files/PowerShell/7" ]; then
           WIN_PATHS="$WIN_PATHS:/mnt/c/Program Files/PowerShell/7"
         fi
         # Only add if not already present
         case ":$PATH:" in
           *":/mnt/c/Windows/System32:"*) : ;;
           *) export PATH="$PATH:$WIN_PATHS" ;;
         esac
       fi

      # Interactive-only setup
      case $- in
        *i*)
          # Starship prompt
          eval "$(starship init bash)"

          # direnv
          eval "$(direnv hook bash)"

          # zoxide (smart cd) with cd override
          eval "$(zoxide init bash --cmd cd)"

          # ble.sh line editor
          source ${pkgs.unstable.blesh}/share/blesh/ble.sh
          bleopt prompt_eol_mark=""

          # Share history across shells/panes in real time
          shopt -s histappend
          PROMPT_COMMAND='history -a; history -n; '"''${PROMPT_COMMAND:-}"

          # Ensure programs pick up truecolor support
          export COLORTERM="truecolor"

          # Theme-integrated ble.sh colors
          ble-face -s region                    fg=${colors.ui.foreground.primary}
          ble-face -s region_target             fg=${colors.ui.foreground.inverse}
          ble-face -s region_match              fg=${colors.ui.foreground.primary}
          ble-face -s region_insert             fg=${colors.ui.interactive.secondary}
          ble-face -s disabled                  fg=${colors.ui.foreground.tertiary}
          ble-face -s overwrite_mode            fg=${colors.ui.foreground.inverse},bg=${colors.ui.interactive.accent}
          ble-face -s vbell                     reverse
          ble-face -s vbell_erase               none
          ble-face -s vbell_flash               fg=${colors.ui.status.success},reverse
          ble-face -s prompt_status_line        fg=${colors.ui.foreground.primary}

          # syntax highlighting (backgrounds removed)
          ble-face -s syntax_default            none
          ble-face -s syntax_command            fg=${colors.terminal.yellow}
          ble-face -s syntax_quoted             fg=${colors.terminal.green}
          ble-face -s syntax_quotation          fg=${colors.terminal.green},bold
          ble-face -s syntax_escape             fg=${colors.terminal.magenta}
          ble-face -s syntax_expr               fg=${colors.terminal.blue}
          ble-face -s syntax_error              fg=${colors.ui.status.error}
          ble-face -s syntax_varname            fg=${colors.palette.highlight}
          ble-face -s syntax_delimiter          bold
          ble-face -s syntax_param_expansion    fg=${colors.terminal.magenta}
          ble-face -s syntax_history_expansion  fg=${colors.terminal.yellow}
          ble-face -s syntax_function_name      fg=${colors.ui.interactive.primary},bold
          ble-face -s syntax_comment            fg=${colors.ui.foreground.tertiary}
          ble-face -s syntax_glob               fg=${colors.ui.status.error},bold
          ble-face -s syntax_brace              fg=${colors.terminal.cyan},bold
          ble-face -s syntax_tilde              fg=${colors.ui.interactive.secondary},bold
          ble-face -s syntax_document           fg=${colors.terminal.green}
          ble-face -s syntax_document_begin     fg=${colors.terminal.green},bold
          # Avoid alarming colors for shell builtins like 'cd'
          ble-face -s command_builtin_dot       fg=${colors.terminal.blue},bold
          ble-face -s command_builtin           fg=${colors.terminal.blue}
          ble-face -s command_alias             fg=${colors.terminal.cyan}
          ble-face -s command_function          fg=${colors.ui.interactive.primary}
          ble-face -s command_file              fg=${colors.terminal.green}
          ble-face -s command_keyword           fg=${colors.terminal.blue}
          ble-face -s command_jobs              fg=${colors.terminal.red}
          ble-face -s command_directory         fg=${colors.terminal.blue},underline
          ble-face -s filename_directory        underline,fg=${colors.terminal.blue}
          ble-face -s filename_directory_sticky underline,fg=${colors.ui.foreground.primary}
          ble-face -s filename_link             underline,fg=${colors.terminal.cyan}
          ble-face -s filename_orphan           underline,fg=${colors.ui.status.warning}
          ble-face -s filename_executable       underline,fg=${colors.terminal.green}
          ble-face -s filename_setuid           underline,fg=${colors.ui.status.warning}
          ble-face -s filename_setgid           underline,fg=${colors.ui.status.warning}
          ble-face -s filename_other            underline
          ble-face -s filename_socket           underline,fg=${colors.terminal.cyan}
          ble-face -s filename_pipe             underline,fg=${colors.terminal.green}
          ble-face -s filename_character        underline,fg=${colors.ui.foreground.primary}
          ble-face -s filename_block            underline,fg=${colors.terminal.yellow}
          ble-face -s filename_warning          underline,fg=${colors.ui.status.error}
          ble-face -s filename_url              underline,fg=${colors.terminal.blue}
          ble-face -s filename_ls_colors        underline
          ble-face -s varname_array             fg=${colors.palette.highlight},bold
          ble-face -s varname_empty             fg=${colors.ui.foreground.tertiary}
          ble-face -s varname_export            fg=${colors.ui.interactive.primary},bold
          ble-face -s varname_expr              fg=${colors.ui.interactive.primary},bold
          ble-face -s varname_hash              fg=${colors.terminal.green},bold
          ble-face -s varname_number            fg=${colors.terminal.green}
          ble-face -s varname_readonly          fg=${colors.ui.interactive.primary}
          ble-face -s varname_transform         fg=${colors.terminal.green},bold
          ble-face -s varname_unset             fg=${colors.ui.foreground.tertiary}
          ble-face -s argument_option           fg=${colors.terminal.cyan}
          ble-face -s argument_error            fg=${colors.ui.status.error}

          # highlighting for completions (backgrounds removed except for selections)
          ble-face -s auto_complete             fg=${colors.ui.foreground.tertiary}

          # XDG-compliant aliases
          alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
        ;;
      esac
    '';
    force = true;
  };
}
