# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  lib,
  inputs,
  user,
  host,
  ...
}:
{
  # Import modular configuration
  imports = [
    # Custom modules
    ./modules

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = user.username;
    homeDirectory = user.homeDirectory;
  };

  # User packages
  home.packages =
    with pkgs.unstable;
    [
      # CLI Tools (always included)
      jq
      fastfetch
      gh
      just
      unzip
      xdg-ninja
      lm_sensors
      ffmpeg
      yt-dlp
      atuin
      fd
      file
      unison
      nb
      rucola
      eza
      onefetch
      poppler-utils
      unipicker
      nodejs
      gcc
      gnumake
    ]
    ++ lib.optionals host.isGraphical [
      # Graphical Tools (only when isGraphical = true)
      hyprpicker
      vesktop
      xdg-desktop-portal-termfilechooser
      # Clipboard tools for Wayland
      wl-clipboard
      cliphist
      # Input configuration
      solaar
      libinput
    ]
    ++ lib.optionals host.isGraphical [
      # Custom graphical packages
      pkgs.setup-background-terminals
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = host.stateVersion;

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

      # Ensure XDG-based nix profile puts its bin paths on PATH, similar to legacy nix.sh
      if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/nix.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/nix.sh"
      elif [ -n "$XDG_STATE_HOME" ] && [ -e "$XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh" ]; then
        . "$XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh"
      elif [ -e "$HOME/.local/state/nix/profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.local/state/nix/profile/etc/profile.d/nix.sh"
      fi

       # Bash history control
       export HISTCONTROL="ignoreboth:erasedups"

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
          # direnv
          eval "$(direnv hook bash)"

          # zoxide (smart cd) with cd override
          eval "$(zoxide init bash --cmd cd)"

          # XDG-compliant aliases
          alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'

          # Launch fish if available and not already in fish
          if command -v fish >/dev/null 2>&1 && [ "$0" != "fish" ] && [ -z "$FISH_VERSION" ]; then
            exec fish
          fi
        ;;
      esac
    '';
    force = true;
  };
}
