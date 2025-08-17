# Rebuild system
with import <nixpkgs> {};
with import ./common.nix;
with lib; rec {
  # Core rebuild pipeline
  rebuildPipeline = {
    hostname,
    username ? null,
    verbose ? false,
    autoCommit ? false,
    skipValidation ? false,
    updateFlakes ? false,
  }: let
    actualUsername =
      if username != null
      then username
      else "$(whoami)";
    buildScript = buildPatterns.nixosBuild {
      inherit hostname verbose;
    };
  in
    wrap {
      name = "rebuild-${hostname}";
      paths = [
        git
        nix
      ];
      description = "Rebuild NixOS configuration for ${hostname}";
      vars = {
        HOSTNAME = hostname;
        USERNAME = actualUsername;
        AUTO_COMMIT =
          if autoCommit
          then "true"
          else "false";
      };
      script =
        # bash
        ''
          # Validate environment
          if [[ ! -f "flake.nix" ]]; then
            error "Must run from the root of nix-config (where flake.nix exists)"
            exit 1
          fi

          ${optionalString updateFlakes ''
            # Update flake inputs
            ${nixUtils.flakeUpdater}/bin/update-flakes || warn "Update failed, continuing anyway..."
          ''}

          ${optionalString (!skipValidation) ''
            # Fast syntax validation
            ${nixUtils.validator}/bin/validate-flake || warn "Validation failed, continuing anyway..."
          ''}

          # Always keep git tree clean prior to rebuild
          ${gitUtils.autoFixup}/bin/auto-fixup "$HOSTNAME"

          # Execute the build
          ${buildScript}

          # Handle commits
          if [[ "$AUTO_COMMIT" == "true" ]]; then
            ${gitUtils.smartCommit}/bin/smart-commit "$HOSTNAME"
          elif ! git diff-index --quiet HEAD -- 2>/dev/null; then
            read -p "Commit changes? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
              ${gitUtils.smartCommit}/bin/smart-commit "$HOSTNAME"
            fi
          fi
        '';
    };

  # Development mode
  devMode = {
    hostname,
    username ? null,
  }: let
    actualUsername =
      if username != null
      then username
      else "$(whoami)";
  in
    wrap {
      name = "dev-rebuild-${hostname}";
      paths = [
        git
        nix
      ];
      description = "Development rebuild for ${hostname}";
      script =
        # bash
        ''
          info "Development rebuild for ${actualUsername}@${hostname}"

          # Skip formatting and validation in dev mode
          sudo nixos-rebuild switch --flake .#${hostname} --impure 2>/dev/null || {
            error "Build failed, try full rebuild"
            exit 1
          }

          success "Rebuild completed"
        '';
    };

  # Multi-target builder
  multiBuilder = targets:
    wrap {
      name = "rebuild-multi";
      paths = [
        git
        nix
      ];
      description = "Build multiple configurations: ${
        concatStringsSep ", " (map (t: t.hostname) targets)
      }";
      script =
        # bash
        ''
          info "Building multiple targets: ${concatStringsSep ", " (map (t: t.hostname) targets)}"

          ${concatMapStringsSep "\n" (target: ''
              info "Building ${target.hostname}..."
              ${rebuildPipeline target}/bin/rebuild-${target.hostname}
            '')
            targets}

          success "All builds completed"
        '';
    };

  # Common workflows
  workflows = {
    # Home rebuild
    quick = hostname:
      rebuildPipeline {
        inherit hostname;
        homeOnly = true;
        skipValidation = true;
      };

    # System rebuild
    full = hostname:
      rebuildPipeline {
        inherit hostname;
        homeOnly = false;
        verbose = true;
      };

    # Development rebuild
    dev = hostname: devMode {inherit hostname;};

    # Auto-committing rebuild
    autoCommit = hostname:
      rebuildPipeline {
        inherit hostname;
        homeOnly = true;
        autoCommit = true;
      };

    # Test multiple hosts
    testAll = hostnames:
      multiBuilder (
        map (h: {
          hostname = h;
          homeOnly = true;
        })
        hostnames
      );
  };

  # Interactive rebuilder
  interactive = wrap {
    name = "interactive-rebuild";
    paths = [
      git
      nix
      coreutils
      gawk
    ];
    description = "Interactive rebuild tool";
    script =
      # bash
      ''
        info "Interactive NixOS Rebuild Tool"
        echo

        # Auto-detect hosts from flake.nix
        if [[ -f flake.nix ]]; then
          info "Available hosts:"
          # Extract nixosConfigurations and homeConfigurations
          nix eval --raw .#nixosConfigurations --apply builtins.attrNames 2>/dev/null | \
            tr '[]"' ' ' | tr ',' '\n' | while read -r host; do
              [[ -n "$host" ]] && echo "  • $host (nixos)"
            done

          nix eval --raw .#homeConfigurations --apply builtins.attrNames 2>/dev/null | \
            tr '[]"' ' ' | tr ',' '\n' | while read -r config; do
              [[ -n "$config" ]] && echo "  • $config (home)"
            done
          echo
        fi

        read -p "Enter hostname: " hostname
        [[ -z "$hostname" ]] && { error "Hostname required"; exit 1; }

        read -p "Rebuild type [quick/full/dev]: " mode

        case "$mode" in
          "dev"|"d")
            ${workflows.dev "$hostname"}/bin/dev-rebuild-$hostname
            ;;
          "full"|"f")
            ${workflows.full "$hostname"}/bin/rebuild-$hostname
            ;;
          *)
            ${workflows.quick "$hostname"}/bin/rebuild-$hostname
            ;;
        esac
      '';
  };

  # All utilities are exported through the rec block
}
