with import <nixpkgs> {};
with lib; rec {
  wrap = {
    name,
    paths ? [],
    vars ? {},
    script,
    description ? "",
  }: let
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
    statusChecker =
      runCommand "git-status" {buildInputs = [git];}
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

          COMMIT_MSG="$(date '+%Y-%m-%d %H:%M'): rebuild $HOSTNAME"
          git commit -m "$COMMIT_MSG"
          success "Changes committed: $COMMIT_MSG"
        '';
    };

    autoFixup = wrap {
      name = "auto-fixup";
      paths = [
        git
        coreutils
      ];
      description = "Create a fixup commit to keep the tree clean";
      script =
        # bash
        ''
          # Ensure we're in a git repo
          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            warn "Not a git repository; skipping auto-fixup"
            exit 0
          fi

          # Skip if tree is clean
          if git diff-index --quiet HEAD -- 2>/dev/null; then
            info "Git tree clean; no fixup needed"
            exit 0
          fi

          # Stage all changes
          git add -A

          # Find the last non-fixup/squash commit (the latest 'true' commit)
          last_true_commit=$(git log --grep '^(fixup!|squash!)' -E --invert-grep -n 1 --pretty=%H 2>/dev/null || true)

          if [[ -n "$last_true_commit" ]]; then
            info "Creating fixup for commit ''${last_true_commit:0:7}"
            if git commit --no-verify --fixup "$last_true_commit" >/dev/null 2>&1; then
              success "Auto fixup commit created"
              exit 0
            else
              warn "--fixup failed; falling back to standard commit"
            fi
          fi

          # Fallback when no prior commit or --fixup failed
          host_part="''${1:-rebuild}"
          msg="chore(auto): autosave before ''${host_part}"
          if git commit --no-verify -m "$msg" >/dev/null 2>&1; then
            success "Committed: $msg"
          else
            error "Failed to create auto commit"
            exit 1
          fi
        '';
    };

    trueCommit = wrap {
      name = "true-commit";
      paths = [
        git
        coreutils
      ];
      description = "Autosquash all fixups into last true commit and set message";
      script =
        # bash
        ''
          set -euo pipefail

          # Parse -m|--message
          MESSAGE=""
          while [[ $# -gt 0 ]]; do
            case "$1" in
              -m|--message)
                MESSAGE="''${2:-}"
                shift 2
                ;;
              *)
                break
                ;;
            esac
          done

          if [[ -z "$MESSAGE" ]]; then
            read -r -p "Commit message: " MESSAGE
          fi

          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            error "Not a git repository"
            exit 1
          fi

          # If there are uncommitted changes, include them in a fixup first
          if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            info "Staging and creating fixup for dirty tree"
            git add -A
            last_true_commit=$(git log --grep '^(fixup!|squash!)' -E --invert-grep -n 1 --pretty=%H 2>/dev/null || true)
            if [[ -n "$last_true_commit" ]]; then
              git commit --no-verify --fixup "$last_true_commit" >/dev/null 2>&1 || true
            else
              # No prior commit; make an initial commit with the provided message
              git commit --no-verify -m "$MESSAGE" >/dev/null 2>&1
              success "Committed initial: $MESSAGE"
              exit 0
            fi
          fi

          # Find last true commit after potential fixup just created
          last_true_commit=$(git log --grep '^(fixup!|squash!)' -E --invert-grep -n 1 --pretty=%H 2>/dev/null || true)
          if [[ -z "$last_true_commit" ]]; then
            error "Could not determine base commit to squash into"
            exit 1
          fi

          # Check if there are fixup/squash commits to process
          if ! git log --pretty=%s "''${last_true_commit}..HEAD" | grep -E '^(fixup!|squash!)' >/dev/null 2>&1; then
            info "No auto commits to squash; creating a new commit"
            # nothing to squash; create a regular commit (fast-path)
            # Use empty tree check to avoid failing when nothing to commit
            if git diff-index --quiet HEAD -- 2>/dev/null; then
              warn "Nothing to commit"
              exit 0
            else
              git add -A
              git commit --no-verify -m "$MESSAGE"
              success "Committed: $MESSAGE"
              exit 0
            fi
          fi

          info "Autosquashing fixups into ''${last_true_commit:0:7}"
          export GIT_SEQUENCE_EDITOR=:
          if ! git rebase -i --autosquash "''${last_true_commit}^"; then
            error "Autosquash rebase failed; aborting"
            git rebase --abort || true
            exit 1
          fi

          # After autosquash, we're on the squashed commit; reword it
          git commit --no-verify --amend -m "$MESSAGE"
          success "Committed (squashed): $MESSAGE"
        '';
    };
  };

  nixUtils = {
    formatter = let
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
    isNixOS =
      runCommand "check-nixos" {buildInputs = [coreutils];}
      # bash
      ''
        if [[ -f /etc/NIXOS ]]; then
          echo "true" > "$out"
        else
          echo "false" > "$out"
        fi
      '';
    getHostname =
      runCommand "get-hostname" {buildInputs = [nettools];}
      # bash
      ''
        hostname > "$out"
      '';
  };

  buildPatterns = {
    homeManagerBuild = {
      hostname,
      username ? "$(whoami)",
      verbose ? false,
    }: let
      verboseFlag =
        if verbose
        then ""
        else ">/dev/null 2>&1";
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

    nixosBuild = {
      hostname,
      verbose ? false,
    }: let
      verboseFlag =
        if verbose
        then ""
        else "2>/dev/null";
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
