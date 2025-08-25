{
  config,
  lib,
  inputs,
  globals,
  ...
}: {
  # Import the nixCats-fish module at the top level
  imports = [
    inputs.nixCats-fish.homeModules.default
  ];

  options.igloo.nixCats-fish.enable =
    lib.mkEnableOption "Enable nixCats-fish shell"
    // {
      default = false;
    };

  config = lib.mkIf config.igloo.nixCats-fish.enable {
    # Enable nixCats-fish
    programs.nixCats-fish = {
      enable = true;
      seedConfig = true;
      # Optionally set as default shell - uncomment if desired
      # setAsDefaultShell = true;
    };

    # Set environment variable to point to repo config for live editing
    # This enables the nixCats philosophy: edit configs in repo, no rebuilds needed
    # Use a dynamic discovery approach instead of hardcoded paths
    home.sessionVariables = {
      # Set a hint about where to look for nixCats configs, but don't hardcode
      NIXCATS_CONFIG_DISCOVERY = "true";
    };
    
    # Add a shell alias that dynamically finds the config
    home.shellAliases = lib.mkIf (config.igloo.nixCats-fish.enable) {
      fishcat-live = ''
        if [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/flakes/nixCats-fish/config" ]; then
          NIXCATS_FISH_DIR="$FLAKE_ROOT/flakes/nixCats-fish/config" fishCats
        elif [ -d "./flakes/nixCats-fish/config" ]; then
          NIXCATS_FISH_DIR="./flakes/nixCats-fish/config" fishCats  
        elif [ -d "../flakes/nixCats-fish/config" ]; then
          NIXCATS_FISH_DIR="../flakes/nixCats-fish/config" fishCats
        else
          echo "nixCats-fish config not found. Run from repo root or set NIXCATS_FISH_DIR"
          fishCats
        fi
      '';
    };
  };
}
