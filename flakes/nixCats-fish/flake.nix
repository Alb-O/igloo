{
  description = "nixCats-fish: A Fish shell configuration manager with category system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Future: Fish plugin inputs could go here
    # "plugins-fish-async-prompt" = { url = "github:acomagu/fish-async-prompt"; flake = false; };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Utility functions (similar to nixCats-nvim)
    utils = rec {
      eachSystem = f: nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] f;

      # Build a Fish package with category system
      baseBuilder = fishConfigPath: {
        nixpkgs,
        system,
        dependencyOverlays,
        extra_pkg_config,
      }: categoryDefinitions: packageDefinitions: packageName: let
        pkgs = import nixpkgs {
          inherit system;
          config = extra_pkg_config;
          overlays = dependencyOverlays;
        };

        # Get package definition
        packageDef = packageDefinitions.${packageName} {
          inherit pkgs;
          name = packageName;
        };
        settings = packageDef.settings or {};
        categories = packageDef.categories or {};
        extra = packageDef.extra or {};

        # Resolve category dependencies
        categoryDefs = categoryDefinitions {
          inherit pkgs settings categories extra;
          name = packageName;
        };

        # Build runtime dependencies based on enabled categories
        runtimeDeps = let
          getDepsFromCategory = catName: catDef: let
            catEnabled = categories.${catName} or false;
            isEnabled =
              if builtins.isBool catEnabled
              then catEnabled
              else builtins.length (builtins.attrNames catEnabled) > 0;
          in
            if isEnabled
            then
              if builtins.isAttrs catDef
              then
                nixpkgs.lib.flatten (nixpkgs.lib.mapAttrsToList (
                    subCat: subDef: let
                      subEnabled =
                        if builtins.isAttrs catEnabled
                        then (catEnabled.${subCat} or false)
                        else true;
                    in
                      if subEnabled
                      then
                        (
                          if builtins.isList subDef
                          then subDef
                          else [subDef]
                        )
                      else []
                  )
                  catDef)
              else if builtins.isList catDef
              then catDef
              else [catDef]
            else [];
        in
          nixpkgs.lib.flatten (
            nixpkgs.lib.mapAttrsToList getDepsFromCategory (categoryDefs.runtimeDeps or {})
          );

        # Create the Fish configuration data available to Fish scripts
        fishCatsData = {
          inherit categories extra settings;
          configDir = fishConfigPath;
          packageName = packageName;
          # Flatten category structure for easier querying
          enabledCategories = let
            flattenCats = prefix: cats:
              nixpkgs.lib.flatten (nixpkgs.lib.mapAttrsToList (
                  k: v: let
                    fullPath =
                      if prefix == ""
                      then k
                      else "${prefix}${k}";
                    catValue = nixpkgs.lib.attrByPath (nixpkgs.lib.splitString "." fullPath) null categories;
                  in
                    if builtins.isAttrs v
                    then
                      (flattenCats (fullPath + ".") v)
                      ++ (
                        if catValue != null && catValue != false
                        then [fullPath]
                        else []
                      )
                    else if catValue == true
                    then [fullPath]
                    else []
                )
                cats);
          in
            flattenCats "" categories;
        };

        # Generate the nixCats Fish integration
        fishCatsIntegration = pkgs.writeTextFile {
          name = "nixcats-fish-integration";
          destination = "/conf.d/000-nixcats.fish";
          text = ''
            # nixCats-fish integration
            # Provides fishCats() function for querying enabled categories

            # Store nixCats data
            set -g __fishcats_data '${builtins.toJSON fishCatsData}'

            function fishCats --description 'Query nixCats categories and configuration'
                if test (count $argv) -eq 0
                    echo "fishCats: Query enabled categories and configuration"
                    echo "Usage:"
                    echo "  fishCats <category>           # Check if category is enabled"
                    echo "  fishCats --list              # List all enabled categories"
                    echo "  fishCats --get <path>        # Get value from extra config"
                    echo ""
                    echo "Examples:"
                    echo "  fishCats fzf                 # Returns 0 if fzf category enabled"
                    echo "  fishCats modern.core         # Check subcategory"
                    echo "  fishCats --get theme         # Get theme from extra config"
                    return 0
                end

                switch $argv[1]
                    case --list
                        echo $__fishcats_data | ${pkgs.jq}/bin/jq -r '.enabledCategories[]' 2>/dev/null
                        return 0

                    case --get
                        if test (count $argv) -lt 2
                            echo "fishCats --get requires a path argument"
                            return 1
                        end
                        set -l value (echo $__fishcats_data | ${pkgs.jq}/bin/jq -r --arg path "$argv[2]" '.extra[$path] // empty' 2>/dev/null)
                        if test -n "$value" -a "$value" != "null"
                            echo $value
                            return 0
                        else
                            return 1
                        end

                    case '*'
                        # Check if category is enabled
                        set -l query $argv[1]

                        # Direct category check
                        set -l enabled (echo $__fishcats_data | ${pkgs.jq}/bin/jq -r --arg cat "$query" '
                          .categories[$cat] //
                          (.categories | to_entries[] | select(.key == ($cat | split(".")[0])) |
                           if (.value | type) == "object" then
                             .value[($cat | split(".")[1:]? | join("."))] // false
                           else .value end) // false
                        ' 2>/dev/null)

                        if test "$enabled" = "true"
                            return 0
                        else
                            return 1
                        end
                end
            end

            # Export useful environment variables
            set -gx NIXCATS_FISH_CONFIG_DIR ${fishConfigPath}
            set -gx NIXCATS_FISH_PACKAGE_NAME ${packageName}
          '';
        };

        # Main Fish wrapper script
        fishWrapper = pkgs.writeShellScript "${packageName}-wrapper" ''
          # Set up runtime PATH with category-based dependencies
          export PATH="${nixpkgs.lib.makeBinPath runtimeDeps}:$PATH"

          # Determine config directory with smart discovery
          configDir=""

          # Priority 1: Explicit NIXCATS_FISH_DIR
          if [ -n "''${NIXCATS_FISH_DIR:-}" ] && [ -d "''${NIXCATS_FISH_DIR}" ]; then
            configDir="$NIXCATS_FISH_DIR"
            echo "Using explicit nixCats-fish config from: $configDir"

          # Priority 2: Auto-discover in common locations (for live editing)
          elif [ -z "$configDir" ]; then
            for candidate in \
              "''${FLAKE_ROOT:-}/flakes/nixCats-fish/config" \
              "$PWD/flakes/nixCats-fish/config" \
              "$(dirname "$PWD")/flakes/nixCats-fish/config" \
              "$HOME/flakes/nixCats-fish/config" \
              "$HOME/dev/*/flakes/nixCats-fish/config"; do

              if [ -d "$candidate" ]; then
                configDir="$candidate"
                echo "Auto-discovered nixCats-fish config at: $configDir"
                break
              fi
            done
          fi

          # Priority 3: Wrapped mode or fallback
          if [ -z "$configDir" ]; then
            if [ "${toString (settings.wrapRc or true)}" = "true" ]; then
              # Wrapped mode: use immutable config from store
              configDir="${fishConfigPath}"
              echo "Using wrapped nixCats-fish config from: $configDir"
            else
              # Fallback: use/create home directory config
              configDir="$HOME/.config/${settings.configDirName or "nixCats-fish"}"

              # Seed config directory if it doesn't exist
              if [ ! -d "$configDir" ]; then
                echo "Seeding nixCats-fish config at: $configDir"
                mkdir -p "$configDir"
                if [ -d "${fishConfigPath}" ]; then
                  cp -r ${fishConfigPath}/* "$configDir/" 2>/dev/null || true
                fi
              fi
              echo "Using fallback nixCats-fish config from: $configDir"
            fi
          fi

          # Launch Fish with our config directory
          export XDG_CONFIG_HOME="$(dirname "$configDir")"
          export FISH_CONFIG_NAME="$(basename "$configDir")"

          # Ensure nixCats integration is available
          export FISH_NIXCATS_INTEGRATION="${fishCatsIntegration}/conf.d/000-nixcats.fish"

          # Launch Fish with explicit config directory and nixCats integration
          exec ${pkgs.fish}/bin/fish --init-command="
            set -gx __fish_config_dir '$configDir'
            source '$FISH_NIXCATS_INTEGRATION'
            if test -f '$configDir/config.fish'
              source '$configDir/config.fish'
            end
          " "$@"
        '';

        # Create the final package
        fishPackage = pkgs.writeShellApplication {
          name = packageName;
          runtimeInputs = [pkgs.fish pkgs.jq] ++ runtimeDeps;
          text = ''exec ${fishWrapper} "$@"'';
        };
      in
        fishPackage
        // {
          # Add passthru for modules and overriding
          passthru = {
            inherit categoryDefinitions packageDefinitions settings categories extra;
            nixCatsPath = fishConfigPath;
          };
        };
    };

    # Configuration
    systems = ["x86_64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    fishConfigPath = ./config;
    extra_pkg_config = {allowUnfree = true;};
    dependencyOverlays = [];

    # Category definitions (similar to nixCats-nvim's categoryDefinitions)
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      ...
    }: {
      # Runtime dependencies organized by category
      runtimeDeps = {
        # Core Fish shell functionality
        general = with pkgs; [fish];

        # Modern CLI tool replacements
        modern = {
          core = with pkgs; [
            eza # ls → eza
            bat # cat → bat
            fd # find → fd
            ripgrep # grep → rg
          ];
          extended = with pkgs; [
            dust # du → dust
            procs # ps → procs
            bottom # top → btm
            hyperfine # benchmarking
          ];
        };

        # Fuzzy finder and search tools
        fzf = with pkgs; [fzf];

        # Navigation and directory tools
        navigation = with pkgs; [
          zoxide # cd → z (smart cd)
          broot # tree with navigation
        ];

        # Development tools
        development = with pkgs; [
          git
          direnv # directory-based env management
          jq # JSON processing
        ];

        # Shell enhancement utilities
        utilities = with pkgs; [
          tealdeer # tldr pages
          nix-tree # explore nix dependencies
        ];

        # WSL-specific tools
        wsl = with pkgs; [
          wslu # WSL utilities
        ];
      };
    };

    # Package definitions (different Fish configurations)
    packageDefinitions = {
      # Full-featured nixCats-fish
      fishCats = {
        pkgs,
        name,
        ...
      }: {
        settings = {
          wrapRc = true;
          configDirName = "nixCats-fish";
          aliases = ["fish"];
        };

        categories = {
          general = true;
          modern = {
            core = true;
            extended = true;
          };
          fzf = true;
          navigation = true;
          development = true;
          utilities = true;
          # Enable WSL-specific tools if running in WSL
          wsl = builtins.getEnv "IS_WSL" == "true";
        };

        extra = {
          theme = "catppuccin-mocha";
          editor = "nvim";
          keyBindings = "vi";
        };
      };

      # Minimal Fish for basic usage
      minimalFish = {
        pkgs,
        name,
        ...
      }: {
        settings = {
          wrapRc = true;
          configDirName = "nixCats-fish-minimal";
          aliases = ["minfish"];
        };

        categories = {
          general = true;
          modern.core = true;
        };

        extra = {
          theme = "default";
        };
      };

      # Development-focused live configuration
      devFish = {
        pkgs,
        name,
        ...
      }: {
        settings = {
          wrapRc = false; # Live editable configuration
          configDirName = "nixCats-fish-dev";
          # Don't hardcode paths - let the wrapper discover dynamically
          aliases = ["devfish"];
        };

        categories = {
          general = true;
          modern = true;
          fzf = true;
          navigation = true;
          development = true;
          utilities = true;
        };

        extra = {
          theme = "catppuccin-mocha";
          editor = "nixCats"; # Use nixCats-nvim
          promptStyle = "custom";
        };
      };
    };

    defaultPackageName = "fishCats";
  in {
    # System-specific outputs
    packages = forEachSystem (system: let
      # Create builder for this system
      nixCatsFishBuilder =
        utils.baseBuilder fishConfigPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;

      # Build default package
      defaultPackage = nixCatsFishBuilder defaultPackageName;
    in
      (builtins.mapAttrs (name: _: nixCatsFishBuilder name) packageDefinitions)
      // {
        default = defaultPackage;
        nixCats-fish = defaultPackage; # Legacy compatibility
      });

    # Development shells
    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      nixCatsFishBuilder =
        utils.baseBuilder fishConfigPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsFishBuilder defaultPackageName;
    in {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [defaultPackage];
        shellHook = ''
          echo "Welcome to nixCats-fish development!"
          echo "Available packages:"
          echo "  fishCats    - Full-featured configuration"
          echo "  minimalFish - Minimal configuration"
          echo "  devFish     - Development live configuration"
          echo ""
          echo "Try: nix run .#fishCats"
        '';
      };
    });

    # Home Manager module
    homeModules = {
      default = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.programs.nixCats-fish;
      in {
        options.programs.nixCats-fish = {
          enable = lib.mkEnableOption "nixCats-fish";

          package = lib.mkOption {
            type = lib.types.package;
            default = self.packages.${pkgs.system}.default;
            description = "The nixCats-fish package to use";
          };

          seedConfig = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to seed configuration files";
          };

          setAsDefaultShell = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to set as default shell";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = [cfg.package];

          # Set as default shell if requested
          home.sessionVariables = lib.mkIf cfg.setAsDefaultShell {
            SHELL = "${cfg.package}/bin/fishCats";
          };
        };
      };
    };

    # NixOS module
    nixosModules = {
      default = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.programs.nixCats-fish;
      in {
        options.programs.nixCats-fish = {
          enable = lib.mkEnableOption "nixCats-fish system-wide";

          package = lib.mkOption {
            type = lib.types.package;
            default = self.packages.${pkgs.system}.default;
            description = "The nixCats-fish package to use";
          };
        };

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [cfg.package];
        };
      };
    };
  };
}
