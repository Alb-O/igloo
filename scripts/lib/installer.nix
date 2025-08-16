# Bootstrap system
with import <nixpkgs> {};
with import ./common.nix;
with lib; rec {
  # Nix installation checker and installer
  nixInstaller = wrap {
    name = "nix-installer";
    paths = [
      curl
      bash
      coreutils
    ];
    description = "Install Nix if not present";
    script =
      # bash
      ''
        if command -v nix &>/dev/null; then
          info "Nix already installed"
          return 0
        fi

        info "Installing Nix..."
        warn "About to download and execute Nix installer from https://nixos.org"
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          error "Installation cancelled by user"
          exit 1
        fi
        curl -L https://nixos.org/nix/install | sh -s -- --daemon

        # Source the profile
        if [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
          source ~/.nix-profile/etc/profile.d/nix.sh
          success "Nix installed and sourced"
        else
          warn "Nix installed but profile not found, may need manual sourcing"
        fi
      '';
  };

  # Nix configuration setup
  nixConfigurator = wrap {
    name = "nix-configurator";
    paths = [coreutils];
    description = "Configure Nix with flakes and trusted users";
    script =
      # bash
      ''
                info "Configuring Nix with flakes support..."

                # User config
                mkdir -p ~/.config/nix
                cat > ~/.config/nix/nix.conf << 'EOF'
        experimental-features = nix-command flakes
        EOF

                # System config (requires sudo) - handle WSL differences
                if ! grep -q "trusted-users.*$(whoami)" /etc/nix/nix.conf 2>/dev/null; then
                  info "Adding $(whoami) to trusted Nix users..."
                  if echo "trusted-users = root $(whoami)" | sudo tee -a /etc/nix/nix.conf >/dev/null 2>&1; then
                    # Restart nix-daemon if available (may not be on WSL)
                    if systemctl is-active nix-daemon &>/dev/null; then
                      sudo systemctl restart nix-daemon
                      success "Added $(whoami) as trusted Nix user and restarted daemon"
                    else
                      success "Added $(whoami) as trusted Nix user"
                      info "Note: nix-daemon not running (normal for WSL)"
                    fi
                  else
                    warn "Could not modify /etc/nix/nix.conf (read-only filesystem)"
                    warn "This is normal for NixOS - warnings about restricted settings can be ignored"
                  fi
                fi

                success "Nix configured"
      '';
  };

  # Repository setup with git configuration
  repoSetup = {
    gitUrl ? null,
    repoDir ? "nix-config",
  }:
    wrap {
      name = "repo-setup";
      paths = [
        git
        coreutils
      ];
      description = "Set up git repository for NixOS configuration";
      vars = {
        GIT_URL = gitUrl;
        REPO_DIR = repoDir;
      };
      script =
        # bash
        ''
          ${
            if gitUrl != null
            then ''
              if [[ -d "$REPO_DIR" ]]; then
                warn "Directory $REPO_DIR already exists, using existing repo"
                cd "$REPO_DIR"
              else
                info "Cloning configuration from $GIT_URL..."
                git clone "$GIT_URL" "$REPO_DIR"
                cd "$REPO_DIR"
                success "Repository cloned"
              fi
            ''
            else ''
              # Check if we're already inside the repo
              if [[ -f "flake.nix" && -d "scripts" ]]; then
                info "Already inside repository"
              elif [[ -d "$REPO_DIR" ]]; then
                info "Using existing $REPO_DIR directory"
                cd "$REPO_DIR"
              else
                error "No git URL provided and not in a repository with flake.nix"
                exit 1
              fi
            ''
          }

          # Environment setup - ensure .env exists
          if [[ ! -f ".env" ]]; then
            if [[ -f ".env.template" ]]; then
              info "Creating .env from template..."
              cp .env.template .env
              warn "Please edit .env with your personal information before proceeding"
              warn "Required fields: NAME, EMAIL, USERNAME, HOSTNAME, MACHINE_ID"
              read -p "Press Enter when you've updated .env, or Ctrl+C to abort"
            else
              error "No .env file found and no .env.template available"
              exit 1
            fi
          fi

          # Load environment variables
          info "Loading environment configuration..."
          set -a  # Export all variables
          source .env
          set +a

          # Validate required variables
          if [[ -z "$NAME" ]] || [[ -z "$EMAIL" ]] || [[ -z "$USERNAME" ]]; then
            error "Missing required variables in .env: NAME, EMAIL, USERNAME"
            error "Please edit .env and set these values"
            exit 1
          fi

          info "Using configuration: $USERNAME ($NAME <$EMAIL>)"
          info "Git repository setup..."

          # Set git configuration from environment
          if ! git config user.name &>/dev/null; then
            git config user.name "$NAME"
            info "Set git name: $NAME"
          fi

          if ! git config user.email &>/dev/null; then
            git config user.email "$EMAIL"
            info "Set git email: $EMAIL"
          fi

          # Ensure repository ownership and permissions
          if [[ -d .git ]]; then
            USER_GROUP=$(id -gn)
            sudo chown -R "$(whoami):$USER_GROUP" .git
            chmod -R u+w .git
            git config --global --add safe.directory "$(pwd)"
          else
            # Initialize if needed
            git init
            git add .
            git commit -m "Initial commit: NixOS/Home Manager configuration"
          fi

          success "Git repository configured"
        '';
    };

  # Home Manager installer
  homeManagerInstaller = wrap {
    name = "home-manager-installer";
    paths = [nix];
    description = "Install and verify Home Manager";
    script =
      # bash
      ''
        info "Installing Home Manager..."

        # Verify Home Manager is available
        if nix run github:nix-community/home-manager/master -- --help &>/dev/null; then
          success "Home Manager available"
        else
          error "Failed to access Home Manager"
          exit 1
        fi
      '';
  };

  # Configuration validator
  configValidator = wrap {
    name = "config-validator";
    paths = [
      nix
      git
    ];
    description = "Validate flake configuration";
    script =
      # bash
      ''
        info "Validating flake configuration..."

        if [[ ! -f flake.nix ]]; then
          error "flake.nix not found - not in project root?"
          exit 1
        fi

        if nix flake check --impure 2>/dev/null; then
          success "Flake configuration is valid"
        else
          warn "Flake check failed, but continuing anyway..."
        fi
      '';
  };

  # Bootstrap pipeline - combines all steps
  bootstrapPipeline = {
    hostname,
    gitUrl ? null,
    repoDir ? "nix-config",
    skipNixInstall ? false,
    autoBootstrap ? false,
  }:
    wrap {
      name = "bootstrap-${hostname}";
      paths = [
        bash
        coreutils
      ];
      description = "Complete bootstrap pipeline for ${hostname}";
      vars = {
        HOSTNAME = hostname;
        AUTO_BOOTSTRAP =
          if autoBootstrap
          then "true"
          else "false";
      };
      script =
        # bash
        ''
          # Prevent running as root
          if [[ $EUID -eq 0 ]]; then
            error "Don't run this script as root. Run as your normal user."
            exit 1
          fi

          info "Bootstrapping NixOS configuration for $HOSTNAME"

          # Detect environment
          if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
            info "WSL environment detected"
            export WSL_ENV=true
          else
            export WSL_ENV=false
          fi

          echo

          ${optionalString (!skipNixInstall) ''
            # Step 1: Install Nix
            ${nixInstaller}/bin/nix-installer
            echo
          ''}

          # Step 2: Configure Nix
          ${nixConfigurator}/bin/nix-configurator
          echo

          # Step 3: Setup repository
          ${repoSetup {inherit gitUrl repoDir;}}/bin/repo-setup
          echo

          # Step 4: Install Home Manager
          ${homeManagerInstaller}/bin/home-manager-installer
          echo

          # Step 5: Validate configuration
          ${configValidator}/bin/config-validator
          echo

          # Step 6: Bootstrap choice
          if [[ "$AUTO_BOOTSTRAP" == "true" ]]; then
            info "Auto-bootstrapping Home Manager configuration..."
            ${(import ./rebuild.nix).workflows.quick hostname}/bin/rebuild-$HOSTNAME
          else
            if [[ "$WSL_ENV" == "true" ]]; then
              echo "WSL Bootstrap Options:"
              echo "1) Home Manager only (recommended for WSL)"
              echo "2) Full NixOS system (for NixOS on WSL)"
              echo "3) Just validate setup (no build)"
            else
              echo "What would you like to bootstrap?"
              echo "1) Home Manager only (recommended for first run)"
              echo "2) Full NixOS system (requires sudo)"
              echo "3) Just validate setup (no build)"
            fi
            read -p "Choice [1-3]: " -n 1 -r choice
            echo

            case $choice in
              1)
                info "Bootstrapping Home Manager configuration..."
                ${(import ./rebuild.nix).workflows.quick hostname}/bin/rebuild-$HOSTNAME
                ;;
              2)
                if [[ "$WSL_ENV" == "true" ]]; then
                  info "Bootstrapping NixOS system for WSL..."
                else
                  info "Bootstrapping full NixOS system..."
                fi
                ${(import ./rebuild.nix).workflows.full hostname}/bin/rebuild-$HOSTNAME
                ;;
              3)
                info "Setup validation complete. You can now run:"
                echo "  ./scripts/bin/rebuild $HOSTNAME"
                ;;
              *)
                warn "Invalid choice. Setup complete but no build performed."
                echo "You can now run: ./scripts/bin/rebuild $HOSTNAME"
                ;;
            esac
          fi

          echo
          success "Bootstrap complete!"
          echo
          info "Next steps:"
          echo "  • Edit your configuration files in the project root"
          echo "  • Run './scripts/bin/rebuild $HOSTNAME' to apply changes"
          echo "  • Use './scripts/bin/rebuild $HOSTNAME --dev' for fast rebuilds"
        '';
    };
}
