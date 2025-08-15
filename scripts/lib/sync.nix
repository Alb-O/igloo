# Generic cross-platform sync framework
with import <nixpkgs> { };
with import ./common.nix;
with lib;

rec {
  # Base sync operation types
  syncTypes = {
    copy = "copy";
    rsync = "rsync";
    symlink = "symlink";
    merge = "merge";
    custom = "custom";
  };

  # Platform detection utilities
  platformDetection = {
    isWSL = runCommand "check-wsl" { buildInputs = [ coreutils ]; }
      # bash
      ''
        if [[ -n "''${WSL_DISTRO_NAME:-}" ]] || 
           grep -qi "microsoft.*wsl" /proc/version 2>/dev/null || 
           [[ -d "/mnt/wsl" ]] || 
           [[ -d "/mnt/c" ]]; then
          echo "true" > "$out"
        else
          echo "false" > "$out"
        fi
      '';

    isNixOS = runCommand "check-nixos" { buildInputs = [ coreutils ]; }
      # bash
      ''
        if [[ -f /etc/NIXOS ]]; then
          echo "true" > "$out"
        else
          echo "false" > "$out"
        fi
      '';
  };

  # Cross-platform path resolution
  pathResolver = {
    # Windows user discovery for WSL
    windowsUserScript =
      # bash
      ''
        windows_users_dir="/mnt/c/Users"
        if [[ ! -d "$windows_users_dir" ]]; then
          error "Cannot access Windows Users directory"
          exit 1
        fi

        windows_user=$(find "$windows_users_dir" -maxdepth 1 -type d -not -name "." -not -name ".." -not -name "Public" -not -name "Default*" -not -name "All Users" -not -name "Users" -printf "%f\n" | head -1)

        if [[ -z "$windows_user" ]]; then
          error "No Windows user directory found"
          exit 1
        fi
      '';

    # Generic path expansion with variable substitution
    expandPath = path: variables:
      # bash
      ''
        expanded_path="${path}"
        ${concatStringsSep "\n" (
          mapAttrsToList (var: value: ''
            expanded_path="''${expanded_path//\$${var}/${value}}"
          '') variables
        )}
      '';
  };

  # Environment validation framework
  createValidator =
    {
      name,
      detection,
      errorMsg ? "Environment validation failed",
    }:
    # bash
    ''
      # ${name} validation
      ${detection}
      if [[ $? -ne 0 ]]; then
        error "${errorMsg}"
        exit 1
      fi
      info "${name} environment detected"
    '';

  # Generic sync operation builder
  syncOperation =
    {
      name,
      description ? "",
      # Source and destination can contain variables like $USER, $WINDOWS_USER
      source,
      destination,
      # Platform requirements
      requiresWSL ? false,
      requiresNixOS ? false,
      # Sync configuration
      syncType ? "copy",
      excludePatterns ? [ ],
      includePatterns ? [ ],
      # Hooks
      preValidation ? "",
      postValidation ? "",
      preSync ? "",
      postSync ? "",
      # Custom sync implementation (for syncType = "custom")
      customSync ? "",
      # Backup configuration
      createBackup ? false,
      backupLocation ? "",
      # Permissions
      preservePermissions ? true,
      setPermissions ? { },
      # Dependencies
      additionalDeps ? [ ],
    }:
    let
      # Build validation script
      validationScript = concatStringsSep "\n" [
        preValidation
        (optionalString requiresWSL ''
          if [[ -z "''${WSL_DISTRO_NAME:-}" ]] && 
             ! grep -qi "microsoft.*wsl" /proc/version 2>/dev/null && 
             [[ ! -d "/mnt/c" ]]; then
            error "This operation requires WSL environment"
            exit 1
          fi
          info "WSL environment detected"
        '')
        (optionalString requiresNixOS ''
          if [[ ! -f /etc/NIXOS ]]; then
            error "This operation requires NixOS"
            exit 1
          fi
          info "NixOS environment detected"
        '')
        (optionalString requiresWSL pathResolver.windowsUserScript)
        postValidation
      ];

      # Build sync script based on type
      syncScript =
        if syncType == "copy" then
          # bash
          ''
            if [[ -d "$expanded_source" ]]; then
              cp -r ${optionalString preservePermissions "-p"} "$expanded_source/"* "$expanded_destination/"
            else
              cp ${optionalString preservePermissions "-p"} "$expanded_source" "$expanded_destination"
            fi
          ''
        else if syncType == "rsync" then
          # bash
          ''
            rsync -av ${optionalString (!preservePermissions) "--no-perms --no-owner --no-group"} \
              ${concatStringsSep " " (map (p: "--exclude='${p}'") excludePatterns)} \
              ${concatStringsSep " " (map (p: "--include='${p}'") includePatterns)} \
              ${if includePatterns != [ ] then "--exclude='*'" else ""} \
              ${
                if hasSuffix "/" source then
                  ''"$expanded_source/" "$expanded_destination/"''
                else
                  ''"$expanded_source" "$expanded_destination"''
              }
          ''
        else if syncType == "symlink" then
          # bash
          ''
            ln -sf "$expanded_source" "$expanded_destination"
          ''
        else if syncType == "merge" then
          # bash
          ''
            # Merge operation - copy files but don't overwrite destination structure
            if [[ -d "$expanded_source" ]]; then
              find "$expanded_source" -type f -exec bash -c '
                rel_path="$1"
                rel_path="''${rel_path#'"$expanded_source"'/}"
                dest_file="'"$expanded_destination"'/$rel_path"
                mkdir -p "$(dirname "$dest_file")"
                cp ${optionalString preservePermissions "-p"} "$1" "$dest_file"
              ' _ {} \;
            else
              cp ${optionalString preservePermissions "-p"} "$expanded_source" "$expanded_destination"
            fi
          ''
        else if syncType == "custom" then
          customSync
        else
          throw "Unknown sync type: ${syncType}";

      # Build permissions script
      permissionsScript = concatStringsSep "\n" (
        mapAttrsToList (path: perm:
          # bash
          ''
            if [[ -e "${path}" ]]; then
              chmod ${perm} "${path}"
            fi
          '') setPermissions
      );

      # All required packages
      allDeps = [
        coreutils
        findutils
      ]
      ++ (optional (syncType == "rsync") rsync)
      ++ additionalDeps;

    in
    wrap {
      name = "sync-${name}";
      paths = allDeps;
      description = if description != "" then description else "Sync ${name} configuration";
      script =
        # bash
        ''
          ${validationScript}

          # Path expansion with discovered variables
          ${optionalString requiresWSL ''
            source_vars="USER:$USER,WINDOWS_USER:$windows_user,HOME:$HOME"
          ''}
          ${optionalString (!requiresWSL) ''
            source_vars="USER:$USER,HOME:$HOME"
          ''}

          # Expand source and destination paths
          expanded_source="${source}"
          expanded_destination="${destination}"

          IFS=',' read -ra var_pairs <<< "$source_vars"
          for pair in "''${var_pairs[@]}"; do
            IFS=':' read -ra var_parts <<< "$pair"
            var_name="''${var_parts[0]}"
            var_value="''${var_parts[1]}"
            expanded_source="''${expanded_source//\$$var_name/$var_value}"
            expanded_destination="''${expanded_destination//\$$var_name/$var_value}"
          done

          # Validate source exists
          if [[ ! -e "$expanded_source" ]]; then
            error "${name} source not found at: $expanded_source"
            exit 1
          fi

          info "Syncing ${name}..."
          info "From: $expanded_source"
          info "To: $expanded_destination"

          # Create backup if requested
          ${optionalString createBackup ''
            if [[ -e "$expanded_destination" ]]; then
              backup_target="${
                if backupLocation != "" then
                  backupLocation
                else
                  "$expanded_destination.backup-$(date +%Y%m%d-%H%M%S)"
              }"
              info "Creating backup at: $backup_target"
              cp -r "$expanded_destination" "$backup_target"
              success "Backup created"
            fi
          ''}

          # Pre-sync hook
          ${preSync}

          # Create destination directory
          mkdir -p "$(dirname "$expanded_destination")"

          # Execute sync operation
          ${syncScript}

          # Apply custom permissions
          ${permissionsScript}

          # Post-sync hook
          ${postSync}

          success "${name} sync complete!"
        '';
    };

  # Application category system
  createCategory = name: apps: {
    inherit name apps;

    # List all apps in category
    list = wrap {
      name = "list-${name}-apps";
      paths = [ coreutils ];
      description = "List ${name} sync applications";
      script =
        # bash
        ''
          echo "${name} Applications:"
          echo "${strings.stringAsChars (c: if c == name then "=" else "=") name}============"
          ${concatStringsSep "\n" (
            mapAttrsToList (appName: appDesc: ''
              echo "  • ${appName} - ${appDesc}"
            '') apps
          )}
        '';
    };
  };

  # Bundle creator for batch operations
  createBundle =
    {
      name,
      operations,
      description ? "",
    }:
    wrap {
      name = "bundle-${name}";
      paths = [ coreutils ];
      description = if description != "" then description else "Execute ${name} bundle";
      script =
        # bash
        ''
          info "Executing ${name} bundle..."
          echo

          ${concatMapStringsSep "\n" (op: ''
            info "Running ${op.name or "operation"}..."
            ${op}/bin/*
            echo
          '') operations}

          success "${name} bundle complete!"
        '';
    };

  # Plugin system for extending sync capabilities
  createPlugin =
    {
      name,
      operations ? { },
      categories ? { },
      bundles ? { },
      setup ? "",
      teardown ? "",
    }:
    {
      inherit
        name
        operations
        categories
        bundles
        ;

      # Plugin initialization
      init = wrap {
        name = "init-${name}-plugin";
        paths = [ coreutils ];
        description = "Initialize ${name} sync plugin";
        script =
          # bash
          ''
            info "Initializing ${name} plugin..."
            ${setup}
            success "${name} plugin initialized"
          '';
      };

      # Plugin cleanup
      cleanup = wrap {
        name = "cleanup-${name}-plugin";
        paths = [ coreutils ];
        description = "Cleanup ${name} sync plugin";
        script =
          # bash
          ''
            info "Cleaning up ${name} plugin..."
            ${teardown}
            success "${name} plugin cleaned up"
          '';
      };

      # Get operation by name
      getOperation =
        name:
        if hasAttr name operations then
          getAttr name operations
        else
          throw "Unknown operation '${name}' in plugin '${name}'";
    };
}
