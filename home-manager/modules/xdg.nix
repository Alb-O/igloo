{
  lib,
  pkgs,
  ...
}:
{
  # XDG Base Directory Specification
  # Sets up proper XDG environment variables and directory structure

  # XDG base directories are enabled at the system level in NixOS configuration
  # (use-xdg-base-directories is set in nixos/modules/xdg.nix)
  nix = {
    package = lib.mkDefault pkgs.nix;
  };

  home.sessionVariables = {
    # Application-specific XDG compliance (don't override base XDG vars - let Home Manager handle them)
    HISTFILE = lib.mkForce "$XDG_STATE_HOME/bash/history";
    CARGO_HOME = lib.mkForce "$XDG_DATA_HOME/cargo";
    CUDA_CACHE_PATH = lib.mkForce "$XDG_CACHE_HOME/nv";
    DOTNET_CLI_HOME = lib.mkForce "$XDG_DATA_HOME/dotnet";
    GTK2_RC_FILES = lib.mkForce "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
    NPM_CONFIG_INIT_MODULE = lib.mkForce "$XDG_CONFIG_HOME/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = lib.mkForce "$XDG_CACHE_HOME/npm";
    NPM_CONFIG_TMP = lib.mkForce "$XDG_RUNTIME_DIR/npm";
    PYTHONSTARTUP = lib.mkForce "$XDG_CONFIG_HOME/python/pythonrc";
    NBRC_PATH = lib.mkForce "$XDG_CONFIG_HOME/nbrc";
    NB_DIR = lib.mkForce "$XDG_DATA_HOME/nb";
  };

  # Create necessary directories and shell configuration
  home.file = {
    # Python startup script for history management
    ".config/python/pythonrc".text = ''
      #!/usr/bin/env python3
      # XDG Base Directory compliant Python history
      # This is unnecessary post v3.13.0a3

      def is_vanilla() -> bool:
          """ :return: whether running "vanilla" Python <3.13 """
          import sys
          return not hasattr(__builtins__, '__IPYTHON__') and 'bpython' not in sys.argv[0] and sys.version_info < (3, 13)

      def setup_history():
          """ read and write history from state file """
          import os
          import atexit
          import readline
          from pathlib import Path

          # Check PYTHON_HISTORY for future-compatibility with Python 3.13
          if history := os.environ.get('PYTHON_HISTORY'):
              history = Path(history)
          # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
          elif state_home := os.environ.get('XDG_STATE_HOME'):
              state_home = Path(state_home)
          else:
              state_home = Path.home() / '.local' / 'state'

          history: Path = history or state_home / 'python_history'

          # https://github.com/python/cpython/issues/105694
          if not history.is_file():
              readline.write_history_file(str(history)) # breaks on macos + python3 without this.

          readline.read_history_file(history)
          atexit.register(readline.write_history_file, history)

      if is_vanilla():
          setup_history()
    '';

    # Create NPM config directory structure
    ".config/npm/config/.keep".text = "";
  };

  # Enable XDG directories with developer-friendly names
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      # Developer-friendly lowercase directory names
      desktop = "$HOME/desktop";
      documents = "$HOME/docs";
      download = "$HOME/dl";
      music = "$HOME/music";
      pictures = "$HOME/pics";
      publicShare = "$HOME/public";
      templates = "$HOME/templates";
      videos = "$HOME/vids";
    };
  };

  # On NixOS, Home Manager's `targets.genericLinux` can generate a default
  # ~/.profile that sources ~/.nix-profile/... This conflicts with
  # nix.settings.use-xdg-base-directories and our explicit .profile that prefers
  # /etc/profiles/per-user (canonical) and XDG STATE paths. We force-disable it
  # here so our managed .profile is linked and used.
  targets.genericLinux.enable = lib.mkForce false;
}
