# Dotfiles sync plugin - demonstrates extensibility of the sync framework
with import <nixpkgs> { };
with import ../common.nix;
with import ../sync.nix;
with lib;

rec {
  # Shell configuration operations
  shellOperations = {
    zshrc = syncOperation {
      name = "zshrc";
      description = "Sync Zsh configuration";
      source = "$HOME/.config/zsh/.zshrc";
      destination = "$HOME/.zshrc";
      syncType = "copy";
      createBackup = true;
    };

    bashrc = syncOperation {
      name = "bashrc";
      description = "Sync Bash configuration";
      source = "$HOME/.config/bash/.bashrc";
      destination = "$HOME/.bashrc";
      syncType = "copy";
      createBackup = true;
    };

    fish-config = syncOperation {
      name = "fish-config";
      description = "Sync Fish shell configuration";
      source = "$HOME/.config/fish";
      destination = "$HOME/.local/share/fish";
      syncType = "rsync";
      excludePatterns = [
        "fish_variables"
        "fishd.*"
      ];
    };
  };

  # Editor configurations
  editorOperations = {
    vimrc = syncOperation {
      name = "vimrc";
      description = "Sync Vim configuration";
      source = "$HOME/.config/vim/.vimrc";
      destination = "$HOME/.vimrc";
      syncType = "copy";
      createBackup = true;

      postSync =
        # bash
        ''
          # Create vim directories if they don't exist
          mkdir -p "$HOME/.vim/"{backup,swap,undo}
          success "Vim directories created"
        '';
    };

    nvim-config = syncOperation {
      name = "nvim-config";
      description = "Sync Neovim configuration";
      source = "$HOME/.config/nvim-source";
      destination = "$HOME/.config/nvim";
      syncType = "rsync";
      excludePatterns = [
        ".git"
        "*.log"
        "plugin/packer_compiled.lua"
      ];

      postSync =
        # bash
        ''
          info "Remember to run :PackerSync in Neovim to update plugins"
        '';
    };

    emacs-config = syncOperation {
      name = "emacs-config";
      description = "Sync Emacs configuration";
      source = "$HOME/.config/emacs-source";
      destination = "$HOME/.emacs.d";
      syncType = "rsync";
      excludePatterns = [
        ".git"
        "auto-save-list"
        "elpa"
        "eln-cache"
      ];
    };
  };

  # Terminal configurations
  terminalOperations = {
    alacritty = syncOperation {
      name = "alacritty";
      description = "Sync Alacritty terminal configuration";
      source = "$HOME/.config/alacritty-source/alacritty.yml";
      destination = "$HOME/.config/alacritty/alacritty.yml";
      syncType = "copy";
    };

    kitty = syncOperation {
      name = "kitty";
      description = "Sync Kitty terminal configuration";
      source = "$HOME/.config/kitty-source";
      destination = "$HOME/.config/kitty";
      syncType = "rsync";
      includePatterns = [
        "kitty.conf"
        "themes/"
        "*.conf"
      ];
    };

    tmux = syncOperation {
      name = "tmux";
      description = "Sync tmux configuration";
      source = "$HOME/.config/tmux/.tmux.conf";
      destination = "$HOME/.tmux.conf";
      syncType = "copy";
      createBackup = true;

      postSync =
        # bash
        ''
          # Reload tmux configuration if tmux is running
          if command -v tmux &> /dev/null && tmux list-sessions &> /dev/null; then
            tmux source-file "$HOME/.tmux.conf"
            success "Reloaded tmux configuration"
          fi
        '';
    };
  };

  # Development tool configurations
  devToolOperations = {
    gitignore-global = syncOperation {
      name = "gitignore-global";
      description = "Sync global gitignore";
      source = "$HOME/.config/git/gitignore_global";
      destination = "$HOME/.gitignore_global";
      syncType = "copy";

      postSync =
        # bash
        ''
          git config --global core.excludesfile "$HOME/.gitignore_global"
          success "Global gitignore configured"
        '';
    };

    cargo-config = syncOperation {
      name = "cargo-config";
      description = "Sync Cargo (Rust) configuration";
      source = "$HOME/.config/cargo-source";
      destination = "$HOME/.cargo";
      syncType = "rsync";
      includePatterns = [
        "config.toml"
        "credentials.toml"
      ];
    };

    npm-config = syncOperation {
      name = "npm-config";
      description = "Sync NPM configuration";
      source = "$HOME/.config/npm/.npmrc";
      destination = "$HOME/.npmrc";
      syncType = "copy";
    };
  };

  # Categories
  categories = {
    shell = createCategory "Shell" {
      zshrc = "Zsh configuration";
      bashrc = "Bash configuration";
      fish-config = "Fish shell configuration";
    };

    editor = createCategory "Editor" {
      vimrc = "Vim configuration";
      nvim-config = "Neovim configuration";
      emacs-config = "Emacs configuration";
    };

    terminal = createCategory "Terminal" {
      alacritty = "Alacritty terminal configuration";
      kitty = "Kitty terminal configuration";
      tmux = "tmux configuration";
    };

    devtools = createCategory "Development Tools" {
      gitignore-global = "Global gitignore configuration";
      cargo-config = "Cargo (Rust) configuration";
      npm-config = "NPM configuration";
    };
  };

  # All operations
  operations = shellOperations // editorOperations // terminalOperations // devToolOperations;

  # Bundles
  bundles = {
    shell = createBundle {
      name = "shell";
      description = "Shell configuration bundle";
      operations = with operations; [
        zshrc
        bashrc
        fish-config
      ];
    };

    editor = createBundle {
      name = "editor";
      description = "Editor configuration bundle";
      operations = with operations; [
        vimrc
        nvim-config
      ];
    };

    terminal = createBundle {
      name = "terminal";
      description = "Terminal application bundle";
      operations = with operations; [
        alacritty
        kitty
        tmux
      ];
    };

    minimal = createBundle {
      name = "minimal";
      description = "Minimal dotfiles setup";
      operations = with operations; [
        bashrc
        vimrc
        tmux
      ];
    };

    full = createBundle {
      name = "full";
      description = "Complete dotfiles setup";
      operations = builtins.attrValues operations;
    };
  };

  # Dotfiles plugin
  plugin = createPlugin {
    name = "dotfiles";
    inherit operations categories bundles;

    setup =
      # bash
      ''
        info "Dotfiles sync plugin provides personal configuration management"
        info "Supports: shell configs, editor configs, terminal configs, dev tools"
        info "Run with: dotfiles-sync <config|bundle>"
      '';

    teardown =
      # bash
      ''
        info "Dotfiles plugin cleanup complete"
      '';
  };

  # Export everything for use
  inherit
    operations
    categories
    bundles
    plugin
    ;

  getSyncUtility =
    name:
    if hasAttr name operations then
      getAttr name operations
    else
      throw "Unknown dotfiles configuration: ${name}";

  listApplications = wrap {
    name = "list-dotfiles-apps";
    paths = [ coreutils ];
    description = "List all available dotfiles sync applications";
    script =
      # bash
      ''
        echo "Dotfiles Configuration Sync Applications"
        echo "======================================="
        echo

        ${concatStringsSep "\n" (
          mapAttrsToList (catName: category: ''
            echo "${category.name}:"
            ${concatStringsSep "\n" (
              mapAttrsToList (name: desc: ''
                echo "  • ${name} - ${desc}"
              '') category.apps
            )}
            echo
          '') categories
        )}

        echo "Bundles:"
        echo "  • shell - Shell configurations (zsh, bash, fish)"
        echo "  • editor - Editor configurations (vim, neovim, emacs)"
        echo "  • terminal - Terminal applications (alacritty, kitty, tmux)"
        echo "  • minimal - Essential dotfiles (bash, vim, tmux)"
        echo "  • full - All available configurations"
        echo
        echo "Usage: dotfiles-sync <config|bundle>"
      '';
  };
}
