with import <nixpkgs> { };
with lib;

rec {
  wrap =
    {
      name,
      paths ? [ ],
      vars ? { },
      script,
      description ? "",
    }:
    let
      pathStr = makeBinPath paths;
      varStr = concatStringsSep "\n" (mapAttrsToList (k: v: "export ${k}=${escapeShellArg v}") vars);
      logPrefix = "[\\033[36m${name}\\033[0m]";
    in
    writeScriptBin name
      # bash
      ''
      #!${bash}/bin/bash
      set -euo pipefail

      log() { printf "${logPrefix} %s\n" "$1" >&2; }
      info() { printf "${logPrefix} \\033[34m→\\033[0m %s\n" "$1" >&2; }
      success() { printf "${logPrefix} \\033[32m✓\\033[0m %s\n" "$1" >&2; }
      error() { printf "${logPrefix} \\033[31m✗\\033[0m %s\n" "$1" >&2; }
      warn() { printf "${logPrefix} \\033[33m⚠\\033[0m %s\n" "$1" >&2; }
      export PATH="${pathStr}:$PATH"
      ${varStr}

      ${optionalString (description != "") ''
        if [[ "''${1:-}" == "--help" ]] || [[ "''${1:-}" == "-h" ]]; then
          echo "${description}"
          echo
          echo "Generated script path: $0"
          echo "Dependencies: ${concatStringsSep ", " (map (p: p.name or (builtins.baseNameOf p)) paths)}"
          exit 0
        fi
      ''}
      ${script}
    '';

  gitUtils = {
    statusChecker = runCommand "git-status" { buildInputs = [ git ]; }
      # bash
      ''
      if [[ -d "${./.}/.git" ]]; then
        cd ${./.}
        if git diff-index --quiet HEAD -- 2>/dev/null; then
          echo "clean" > "$out"
        else
          echo "dirty" > "$out"
        fi
      else
        echo "no-git" > "$out"
      fi
    '';
    smartCommit = wrap {
      name = "smart-commit";
      paths = [
        git
        coreutils
      ];
      description = "Git commit with optional AI-generated messages";
      script =
        # bash
        ''
          if git diff-index --quiet HEAD -- 2>/dev/null; then
            info "No changes to commit"
            exit 0
          fi
          HOSTNAME="''${1:-unknown}"
          # Stage changes first
          git add -A

          if command -v gmc &>/dev/null && [[ -n "''${GEMINI_API_KEY:-}" ]]; then
            info "Attempting AI-generated commit message..."
            if gmc config key set "$GEMINI_API_KEY" &>/dev/null && gmc -y &>/dev/null; then
              # Get the actual commit message that was just created
              LAST_COMMIT_MSG="$(git log -1 --pretty=%s 2>/dev/null || echo "AI-generated commit")"
              success "Changes committed with AI message: $LAST_COMMIT_MSG"
              exit 0
            fi
            warn "AI commit failed, falling back to standard message"
          fi
          COMMIT_MSG="$(date '+%Y-%m-%d %H:%M'): rebuild $HOSTNAME"
          git commit -m "$COMMIT_MSG"
          success "Changes committed: $COMMIT_MSG"
        '';
    };
  };

  nixUtils = {
    formatter =
      let
        nixFiles = filterAttrs (name: type: type == "regular" && hasSuffix ".nix" name) (readDir ./.);
      in
      runCommand "nix-format"
        {
          buildInputs = [
            nixpkgs-fmt
            git
          ];
        }
        # bash
        ''
          cp -r ${./.} ./repo
          chmod -R +w ./repo
          cd ./repo
          if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            echo "Formatting Nix files..."
            find . -name "*.nix" -exec nixpkgs-fmt {} \;
          fi
          cp -r . "$out"
        '';

    validator = wrap {
      name = "validate-flake";
      paths = [
        nix
        git
      ];
      description = "Fast flake syntax validation";
      script =
        # bash
        ''
          info "Validating flake configuration..."
          if [[ ! -f "flake.nix" ]]; then
            error "No flake.nix found in current directory"
            exit 1
          fi
          if nix-instantiate --parse flake.nix >/dev/null 2>/dev/null; then
            success "Flake configuration is valid"
          else
            warn "Flake syntax check failed, but continuing..."
            return 1
          fi
        '';
    };
    fullValidator = wrap {
      name = "validate-flake-full";
      paths = [
        nix
        git
      ];
      description = "Complete flake validation (includes evaluation)";
      script =
        # bash
        ''
          info "Full flake validation (this may take time)..."
          if [[ ! -f "flake.nix" ]]; then
            error "No flake.nix found in current directory"
            exit 1
          fi
          if nix flake check --impure 2>/dev/null; then
            success "Flake configuration is fully valid"
          else
            warn "Flake check failed, but continuing..."
            return 1
          fi
        '';
    };
    flakeUpdater = wrap {
      name = "update-flakes";
      paths = [
        nix
        git
      ];
      description = "Update all flake inputs";
      script =
        # bash
        ''
          info "Updating flake inputs..."
          if [[ ! -f "flake.nix" ]]; then
            error "No flake.nix found in current directory"
            exit 1
          fi
          if nix flake update 2>/dev/null; then
            success "Flake inputs updated successfully"
          else
            warn "Flake update failed, but continuing..."
            return 1
          fi
        '';
    };
  };

  systemUtils = {
    isNixOS = runCommand "check-nixos" { buildInputs = [ coreutils ]; }
      # bash
      ''
        if [[ -f /etc/NIXOS ]]; then
          echo "true" > "$out"
        else
          echo "false" > "$out"
        fi
      '';
    getHostname = runCommand "get-hostname" { buildInputs = [ nettools ]; }
      # bash
      ''
        hostname > "$out"
      '';
  };

  buildPatterns = {
    homeManagerBuild =
      {
        hostname,
        username ? "$(whoami)",
        verbose ? false,
      }:
      let
        verboseFlag = if verbose then "" else ">/dev/null 2>&1";
        buildCmd = "nix run github:nix-community/home-manager/master -- switch --flake .#${username}@${hostname} --impure";
      in
        # bash
        ''
          info "Building home-manager configuration for ${username}@${hostname}..."
          if ${buildCmd} ${verboseFlag}; then
            success "Home-manager configuration applied successfully"
          else
            error "Home-manager build failed"
            ${optionalString (!verbose) ''error "Re-run with --verbose to see detailed output"''}
            exit 1
          fi
        '';

    nixosBuild =
      {
        hostname,
        verbose ? false,
      }:
      let
        verboseFlag = if verbose then "" else "2>/dev/null";
        buildCmd = "sudo nixos-rebuild switch --flake .#${hostname} --impure";
      in
        # bash
        ''
          info "Building NixOS configuration for ${hostname}..."
          if ${buildCmd} ${verboseFlag}; then
            success "NixOS configuration applied successfully"  
          else
            error "NixOS build failed"
            ${optionalString (!verbose) ''error "Re-run with --verbose to see detailed output"''}
            exit 1
          fi
        '';
  };

}
