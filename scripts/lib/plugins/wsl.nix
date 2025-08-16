# WSL sync plugin using the generic sync framework
with import <nixpkgs> {};
with import ../common.nix;
with import ../sync.nix;
with lib; rec {
  # Firefox operations
  firefoxOperations = {
    # Complete Firefox sync (WSL → Windows)
    firefox = syncOperation {
      name = "firefox";
      description = "Complete Firefox sync from WSL to Windows";
      requiresWSL = true;
      source = "$HOME/.mozilla/firefox";
      destination = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Mozilla/Firefox";
      syncType = "custom";
      createBackup = true;
      backupLocation = "/mnt/c/Users/$WINDOWS_USER/Documents/Firefox-Backup-$(date +%Y%m%d-%H%M%S)";

      preSync =
        # bash
        ''
          warn "This will overwrite your Windows Firefox configuration with WSL settings"
          read -p "Are you sure you want to continue? [y/N] " -n 1 -r
          echo
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Sync cancelled"
            exit 0
          fi
        '';

      customSync =
        # bash
        ''
          # Copy profiles.ini
          if [[ -f "$expanded_source/profiles.ini" ]]; then
            cp "$expanded_source/profiles.ini" "$expanded_destination/"
            success "Synced profiles.ini"
          fi

          # Handle nixos profile with NixOS configuration
          nixos_user_js="$HOME/.mozilla/firefox/nixos/user.js"
          if [[ -f "$nixos_user_js" ]] || [[ -L "$nixos_user_js" ]]; then
            target_nixos_profile="$expanded_destination/nixos"
            mkdir -p "$target_nixos_profile"

            real_user_js=$(readlink -f "$nixos_user_js")
            if [[ -f "$real_user_js" ]]; then
              cp "$real_user_js" "$target_nixos_profile/user.js"
              success "Copied NixOS Firefox preferences"
            fi

            # Copy essential files
            for file in places.sqlite bookmarks.html; do
              if [[ -f "$HOME/.mozilla/firefox/nixos/$file" ]]; then
                cp "$HOME/.mozilla/firefox/nixos/$file" "$target_nixos_profile/"
                info "Copied $file"
              fi
            done
          fi
        '';

      postSync =
        # bash
        ''
          success "Firefox configuration synced!"
          warn "Close and restart Firefox on Windows to see changes"
        '';
    };

    firefox-bookmarks = syncOperation {
      name = "firefox-bookmarks";
      description = "Sync Firefox bookmarks only";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Mozilla/Firefox";
      destination = "$HOME/.mozilla/firefox";
      syncType = "custom";

      customSync =
        # bash
        ''
          find "$expanded_source/Profiles" -name "places.sqlite" 2>/dev/null | while read -r places_file; do
            profile_path=$(dirname "$places_file")
            profile_name=$(basename "$profile_path")
            target_profile="$expanded_destination/Profiles/$profile_name"

            mkdir -p "$target_profile"
            cp "$places_file" "$target_profile/"
            info "Synced bookmarks for profile: $profile_name"
          done
        '';
    };
  };

  # VSCode operations
  vscodeOperations = {
    vscode = syncOperation {
      name = "vscode";
      description = "Complete VSCode sync from Windows to WSL";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Code/User";
      destination = "$HOME/.config/Code/User";
      syncType = "rsync";
      includePatterns = [
        "settings.json"
        "keybindings.json"
        "snippets/"
        "tasks.json"
        "launch.json"
      ];

      postSync =
        # bash
        ''
          success "VSCode configuration synced!"
          info "Extensions need to be installed manually in WSL VSCode"
        '';
    };

    vscode-settings = syncOperation {
      name = "vscode-settings";
      description = "Sync VSCode settings only";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Code/User/settings.json";
      destination = "$HOME/.config/Code/User/settings.json";
      syncType = "copy";
    };

    vscode-keybindings = syncOperation {
      name = "vscode-keybindings";
      description = "Sync VSCode keybindings only";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Code/User/keybindings.json";
      destination = "$HOME/.config/Code/User/keybindings.json";
      syncType = "copy";
    };

    vscode-snippets = syncOperation {
      name = "vscode-snippets";
      description = "Sync VSCode snippets";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Code/User/snippets";
      destination = "$HOME/.config/Code/User/snippets";
      syncType = "rsync";
    };

    vscode-extensions = wrap {
      name = "vscode-extensions-export";
      paths = [
        coreutils
        findutils
      ];
      description = "Export VSCode extensions list from Windows";
      script =
        # bash
        ''
          if [[ -z "''${WSL_DISTRO_NAME:-}" ]] &&
             ! grep -qi "microsoft.*wsl" /proc/version 2>/dev/null; then
            error "This operation requires WSL environment"
            exit 1
          fi

          ${pathResolver.windowsUserScript}

          windows_vscode="/mnt/c/Users/$windows_user/AppData/Roaming/Code"
          extensions_file="$HOME/vscode-extensions.txt"

          if [[ -f "$windows_vscode/User/extensions.json" ]]; then
            grep -o '"identifier":{"id":"[^"]*"' "$windows_vscode/User/extensions.json" | \
              sed 's/"identifier":{"id":"//g' | sed 's/"//g' > "$extensions_file"
            success "Extensions list exported to: $extensions_file"
            info "Install with: cat $extensions_file | xargs -I {} code --install-extension {}"
          else
            warn "Extensions list not found"
          fi
        '';
    };
  };

  # Git operations
  gitOperations = {
    git = syncOperation {
      name = "git-full";
      description = "Complete Git setup for WSL";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/.gitconfig";
      destination = "$HOME/.gitconfig";
      syncType = "copy";

      postSync =
        # bash
        ''
          # Fix Windows paths in gitconfig
          if [[ -f "$HOME/.gitconfig" ]]; then
            sed -i 's|C:\\\\|/mnt/c/|g' "$HOME/.gitconfig"
            sed -i 's|\\\\|/|g' "$HOME/.gitconfig"
            success "Updated paths in .gitconfig for WSL"
          fi

          # Setup Git credential manager
          git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
          success "Git credentials configured"

          # Sync SSH keys
          ${gitOperations.git-ssh}/bin/sync-git-ssh
        '';
    };

    git-config = syncOperation {
      name = "git-config";
      description = "Sync Git configuration only";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/.gitconfig";
      destination = "$HOME/.gitconfig";
      syncType = "copy";

      postSync =
        # bash
        ''
          sed -i 's|C:\\\\|/mnt/c/|g' "$HOME/.gitconfig"
          sed -i 's|\\\\|/|g' "$HOME/.gitconfig"
          success "Updated paths in .gitconfig for WSL"
        '';
    };

    git-ssh = syncOperation {
      name = "git-ssh";
      description = "Sync SSH keys with proper permissions";
      requiresWSL = true;
      source = "/mnt/c/Users/$WINDOWS_USER/.ssh";
      destination = "$HOME/.ssh";
      syncType = "custom";
      createBackup = true;

      customSync =
        # bash
        ''
          mkdir -p "$expanded_destination"
          chmod 700 "$expanded_destination"

          for key_file in "id_rsa" "id_ed25519" "id_ecdsa" "id_dsa"; do
            if [[ -f "$expanded_source/$key_file" ]]; then
              cp "$expanded_source/$key_file" "$expanded_destination/"
              chmod 600 "$expanded_destination/$key_file"
              success "Synced private key: $key_file"
            fi

            if [[ -f "$expanded_source/$key_file.pub" ]]; then
              cp "$expanded_source/$key_file.pub" "$expanded_destination/"
              chmod 644 "$expanded_destination/$key_file.pub"
              success "Synced public key: $key_file.pub"
            fi
          done

          for config_file in "config" "known_hosts"; do
            if [[ -f "$expanded_source/$config_file" ]]; then
              cp "$expanded_source/$config_file" "$expanded_destination/"
              chmod 600 "$expanded_destination/$config_file"
              success "Synced $config_file"
            fi
          done
        '';
    };
  };

  # Application categories
  categories = {
    browser = createCategory "Browser" {
      firefox = "Complete Firefox configuration (WSL → Windows)";
      firefox-bookmarks = "Firefox bookmarks only (Windows → WSL)";
      firefox-extensions = "Firefox extensions only (Windows → WSL)";
    };

    development = createCategory "Development" {
      vscode = "Complete VSCode configuration (Windows → WSL)";
      vscode-settings = "VSCode settings only";
      vscode-keybindings = "VSCode keybindings only";
      vscode-snippets = "VSCode snippets only";
      vscode-extensions = "Export VSCode extensions list";
      git = "Complete Git setup (config, credentials, SSH)";
      git-config = "Git configuration only";
      git-ssh = "SSH keys for Git";
    };
  };

  # All operations registry
  operations = firefoxOperations // vscodeOperations // gitOperations;

  # Bundle definitions
  bundles = {
    dev = createBundle {
      name = "dev";
      description = "Development tools bundle";
      operations = [
        operations.git
        operations.vscode
      ];
    };

    browser = createBundle {
      name = "browser";
      description = "Browser configuration bundle";
      operations = [operations.firefox];
    };

    all = createBundle {
      name = "all";
      description = "Complete configuration bundle";
      operations = [
        operations.firefox
        operations.vscode
        operations.git
      ];
    };
  };

  # WSL plugin definition
  plugin = createPlugin {
    name = "wsl";
    inherit operations categories bundles;

    setup =
      # bash
      ''
        info "WSL sync plugin provides cross-platform configuration synchronization"
        info "Available categories: browser, development"
        info "Available bundles: dev, browser, all"
      '';

    teardown =
      # bash
      ''
        info "WSL sync plugin cleanup complete"
      '';
  };

  # Legacy compatibility - expose operations directly
  inherit operations categories bundles;

  # Helper functions for CLI compatibility
  getSyncUtility = name:
    if hasAttr name operations
    then getAttr name operations
    else throw "Unknown sync configuration: ${name}";

  listApplications = wrap {
    name = "list-wsl-apps";
    paths = [coreutils];
    description = "List all available WSL sync applications";
    script =
      # bash
      ''
        echo "WSL Configuration Sync Applications"
        echo "=================================="
        echo

        ${concatStringsSep "\n" (
          mapAttrsToList (catName: category: ''
            echo "${category.name}:"
            ${concatStringsSep "\n" (
              mapAttrsToList (name: desc: ''
                echo "  • ${name} - ${desc}"
              '')
              category.apps
            )}
            echo
          '')
          categories
        )}

        echo "Bundles:"
        echo "  • dev - Development tools (Git + VSCode)"
        echo "  • browser - Browser configuration (Firefox)"
        echo "  • all - Complete setup"
        echo
        echo "Usage: wsl-sync <app|bundle>"
      '';
  };
}
