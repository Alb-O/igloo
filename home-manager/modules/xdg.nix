{ lib, pkgs, ... }:
let
  mkVars = prefix: mapping: lib.mapAttrs (_: value: "${prefix}/${value}") mapping;

  sessionVars =
    mkVars "$XDG_STATE_HOME" {
      HISTFILE = "bash/history";
    }
    // mkVars "$XDG_DATA_HOME" {
      CARGO_HOME = "cargo";
      DOTNET_CLI_HOME = "dotnet";
      NB_DIR = "nb";
      CODEX_HOME = "codex";
      GOPATH = "go";
    }
    // mkVars "$XDG_CACHE_HOME" {
      CUDA_CACHE_PATH = "nv";
      XCOMPOSECACHE = "X11/xcompose";
      NPM_CONFIG_CACHE = "npm";
    }
    // mkVars "$XDG_CONFIG_HOME" {
      GTK2_RC_FILES = "gtk-2.0/gtkrc";
      NPM_CONFIG_INIT_MODULE = "npm/config/npm-init.js";
      NBRC_PATH = "nbrc";
      PYTHONSTARTUP = "python/pythonrc.py";
    }
    // {
      NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
    };

  yaziWrapper =
    pkgs.writeShellScript "xdg-yazi-wrapper" ''
      set -eu

      multiple="$1"
      directory="$2"
      save="$3"
      path="$4"
      out="$5"

      if [ "$save" = "1" ]; then
        set -- --chooser-file="$out" "$path"
      elif [ "$directory" = "1" ]; then
        set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
      elif [ "$multiple" = "1" ]; then
        set -- --chooser-file="$out" "$path"
      else
        set -- --chooser-file="$out" "$path"
      fi

      exec kitty --title 'XDG File Picker' ${pkgs.yazi}/bin/yazi "$@"

      if [ "$directory" = "1" ] && [ ! -s "$out" ] && [ -s "$out"".1" ]; then
        cat "$out"".1" > "$out"
        rm "$out"".1"
      fi
    '';
in
{
  # XDG Base Directory Specification
  # Sets up proper XDG environment variables and directory structure

  # XDG base directories are enabled at the system level in NixOS configuration
  # (use-xdg-base-directories is set in nixos/modules/xdg.nix)
  # Ensure Home Manager itself uses XDG base dirs for its profile management
  # so that hm-session-vars and home-path land under "$XDG_STATE_HOME/nix/profile"
  # and Home Manager uses `nix profile` semantics instead of legacy nix-env.
  nix = {
    enable = true;
    settings.use-xdg-base-directories = true;
    package = lib.mkDefault pkgs.nix;
  };

  home.sessionVariables = sessionVars;

  # Create necessary directories and shell configuration
  home.file = {
    # Terminal file chooser configuration
    ".config/xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=$HOME/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME
      env=TERMCMD=kitty --title 'XDG File Picker'
      open_mode=suggested
      save_mode=suggested
    '';

    # XDG Desktop Portal configuration - prefer terminal file chooser
    ".config/xdg-desktop-portal/portals.conf".text = ''
      [preferred]
      org.freedesktop.impl.portal.FileChooser=termfilechooser
    '';

    # Custom yazi wrapper script with Nix paths
    ".config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
      source = yaziWrapper;
      executable = true;
    };
    # Python startup script for history management
    ".config/python/pythonrc.py" = {
      source = ../dotfiles/python/pythonrc.py;
      executable = true;
    };

    # Create NPM config directory structure
    ".config/npm/config/.keep".text = "";
  };

  # Enable XDG directories with developer-friendly names
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/desktop";
      documents = "$XDG_DESKTOP_DIR/docs";
      download = "$XDG_DESKTOP_DIR/dl";
      music = "$XDG_DESKTOP_DIR/music";
      pictures = "$XDG_DESKTOP_DIR/pics";
      videos = "$XDG_DESKTOP_DIR/vids";
      templates = "$XDG_DESKTOP_DIR/templates";
      publicShare = "$XDG_DESKTOP_DIR/public";
    };
  };

  # On NixOS, Home Manager's `targets.genericLinux` can generate a default
  # ~/.profile that sources ~/.nix-profile/... This conflicts with
  # nix.settings.use-xdg-base-directories and our explicit .profile that prefers
  # /etc/profiles/per-user (canonical) and XDG STATE paths. We force-disable it
  # here so our managed .profile is linked and used.
  targets.genericLinux.enable = lib.mkForce false;
}
