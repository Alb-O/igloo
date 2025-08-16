# Simplified unison-based sync system
with import <nixpkgs> {};
with import ./common.nix;
with lib; rec {
  # Simple unison wrapper that handles the complexities
  createUnisonSync = {
    name,
    description ? "",
    source,
    destination,
    # Direction: "force-source" (WSL→Windows) or "force-dest" (Windows→WSL)
    direction ? "force-source",
    requiresWSL ? false,
    # Additional unison options
    extraOptions ? [],
    # Optional backup
    backup ? false,
    # Pre/post hooks (minimal)
    preSync ? "",
    postSync ? "",
  }: let
    # Get Windows user for path resolution
    getWindowsUser = ''
      WINDOWS_USER=$(find /mnt/c/Users -maxdepth 1 -type d -not -name "." -not -name ".." -not -name "Public" -not -name "Default*" -not -name "All Users" -printf "%f\n" | head -1)
      if [[ -z "$WINDOWS_USER" ]]; then
        error "Cannot find Windows user directory"
        exit 1
      fi
    '';

    # Expand path variables
    expandPaths = ''
      SOURCE_PATH="${source}"
      DEST_PATH="${destination}"
      SOURCE_PATH="''${SOURCE_PATH//\$WINDOWS_USER/$WINDOWS_USER}"
      DEST_PATH="''${DEST_PATH//\$WINDOWS_USER/$WINDOWS_USER}"
      SOURCE_PATH="''${SOURCE_PATH//\$USER/$USER}"
      DEST_PATH="''${DEST_PATH//\$USER/$USER}"
      SOURCE_PATH="''${SOURCE_PATH//\$HOME/$HOME}"
      DEST_PATH="''${DEST_PATH//\$HOME/$HOME}"
    '';

    # Force direction flag
    forceFlag =
      if direction == "force-source"
      then "$SOURCE_PATH"
      else "$DEST_PATH";

    # Build unison command
    unisonCmd = ''
      unison "$SOURCE_PATH" "$DEST_PATH" \
        -batch \
        -force ${forceFlag} \
        ${concatStringsSep " " extraOptions}
    '';
  in
    wrap {
      name = "unison-sync-${name}";
      paths = [coreutils findutils unison];
      description =
        if description != ""
        then description
        else "Unison sync: ${name}";
      script = ''
        ${optionalString requiresWSL ''
          # Verify WSL environment
          if [[ -z "''${WSL_DISTRO_NAME:-}" ]] && ! grep -qi "microsoft.*wsl" /proc/version 2>/dev/null && [[ ! -d "/mnt/c" ]]; then
            error "This sync requires WSL environment"
            exit 1
          fi

          ${getWindowsUser}
        ''}

        ${expandPaths}

        # Validate paths exist
        if [[ ! -e "$SOURCE_PATH" ]]; then
          error "Source path does not exist: $SOURCE_PATH"
          exit 1
        fi

        # Create destination parent directory
        mkdir -p "$(dirname "$DEST_PATH")"

        info "Syncing ${name}: $SOURCE_PATH → $DEST_PATH"

        ${preSync}

        ${optionalString backup ''
          # Create backup if destination exists
          if [[ -e "$DEST_PATH" ]]; then
            BACKUP_PATH="$DEST_PATH.backup-$(date +%Y%m%d-%H%M%S)"
            info "Creating backup: $BACKUP_PATH"
            cp -r "$DEST_PATH" "$BACKUP_PATH"
          fi
        ''}

        # Execute unison sync
        ${unisonCmd}

        ${postSync}

        success "${name} sync completed successfully"
      '';
    };

  # Firefox sync (WSL → Windows, force overwrite)
  firefoxSync = createUnisonSync {
    name = "firefox";
    description = "Firefox configuration sync (WSL → Windows)";
    source = "$HOME/.mozilla/firefox";
    destination = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Mozilla/Firefox";
    direction = "force-source";
    requiresWSL = true;
    backup = true;
    extraOptions = ["-ignore 'Path lock'" "-ignore 'Path *.lock'"];
    preSync = ''
      warn "This will overwrite Windows Firefox configuration with WSL settings"
      info "Firefox will be forcibly updated - make sure Firefox is closed on Windows"
    '';
    postSync = ''
      success "Firefox configuration synced to Windows"
      warn "Restart Firefox on Windows to see changes"
    '';
  };

  # VSCode sync (WSL → Windows)
  vscodeSync = createUnisonSync {
    name = "vscode";
    description = "VSCode configuration sync (WSL → Windows)";
    source = "$HOME/.config/Code/User";
    destination = "/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Code/User";
    direction = "force-source";
    requiresWSL = true;
    backup = true;
    extraOptions = [
      "-ignore 'Path logs'"
      "-ignore 'Path workspaceStorage'"
      "-ignore 'Path extensions'"
    ];
  };

  # Git config sync (WSL → Windows)
  gitSync = createUnisonSync {
    name = "git";
    description = "Git configuration sync (WSL → Windows)";
    source = "$HOME";
    destination = "/mnt/c/Users/$WINDOWS_USER";
    direction = "force-source";
    requiresWSL = true;
    backup = true;
    extraOptions = [
      "-path .gitconfig"
      "-path .ssh"
      "-ignore 'Path .ssh/known_hosts.old'"
    ];
    postSync = ''
      # Fix WSL paths in Windows gitconfig
      if [[ -f "/mnt/c/Users/$WINDOWS_USER/.gitconfig" ]]; then
        sed -i 's|/mnt/c/|C:\\\\|g' "/mnt/c/Users/$WINDOWS_USER/.gitconfig"
        sed -i 's|/|\\\\|g' "/mnt/c/Users/$WINDOWS_USER/.gitconfig"
        success "Fixed paths in Windows .gitconfig"
      fi
    '';
  };

  # Bundle operations
  devBundle = wrap {
    name = "unison-dev-bundle";
    paths = [coreutils];
    description = "Development tools bundle (Git + VSCode)";
    script = ''
      info "Executing development bundle sync..."
      ${gitSync}/bin/unison-sync-git
      ${vscodeSync}/bin/unison-sync-vscode
      success "Development bundle sync complete"
    '';
  };

  allBundle = wrap {
    name = "unison-all-bundle";
    paths = [coreutils];
    description = "Complete configuration bundle";
    script = ''
      info "Executing complete sync bundle..."
      ${firefoxSync}/bin/unison-sync-firefox
      ${gitSync}/bin/unison-sync-git
      ${vscodeSync}/bin/unison-sync-vscode
      success "Complete bundle sync finished"
    '';
  };

  # Available operations
  operations = {
    inherit firefoxSync vscodeSync gitSync;
    firefox = firefoxSync;
    vscode = vscodeSync;
    git = gitSync;
  };

  # Available bundles
  bundles = {
    dev = devBundle;
    all = allBundle;
  };

  # Utility to get sync operation by name
  getSyncUtility = name:
    if hasAttr name operations
    then getAttr name operations
    else throw "Unknown unison sync: ${name}. Available: firefox, vscode, git";
}
