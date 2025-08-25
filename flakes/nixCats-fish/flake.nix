{
  description = "nixCats-fish: Fish shell with editable XDG config and fzf integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkPkg = system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Categories for optional runtime deps
      categories = {
        core = with pkgs; [fish];
        nav = with pkgs; [zoxide];
        fzf = with pkgs; [fzf];
        env = with pkgs; [direnv];
        tools = with pkgs; [fd ripgrep bat eza];
      };

      # Merge selected categories
      selected = builtins.concatLists [
        categories.core
        categories.fzf
        categories.env
        categories.nav
        categories.tools
      ];

      # Default, read-only config in store for fallback use only
      defaultConfig = pkgs.runCommand "nixCats-fish-config" {} ''
        mkdir -p $out
        cp -r ${./config}/* $out/
        # Template substitution for fish config
        substituteInPlace $out/config.fish \
          --subst-var-by FZF_PATH "${pkgs.fzf}" \
          --subst-var-by FD_PATH "${pkgs.fd}" \
          --subst-var-by BAT_PATH "${pkgs.bat}"
      '';

      # The fish config that the wrapper uses.
      # Runtime resolution:
      # - if $NIXCATS_FISH_DIR/config.fish exists, use it (editable in your checkout)
      # - else if $XDG_CONFIG_HOME/nixCats-fish/config.fish exists, use it (user-managed)
      # - else: use the built-in default (read-only) from the store
      wrapperScript = pkgs.writeShellScript "fishcat-wrapper" ''
        : "''${XDG_CONFIG_HOME:=$HOME/.config}"
        : "''${XDG_DATA_HOME:=$HOME/.local/share}"
        : "''${XDG_STATE_HOME:=$HOME/.local/state}"

        # Provide package paths for user config to reference without rebuilds
        export NIXCATS_FZF_PATH="${pkgs.fzf}"
        export NIXCATS_FD_PATH="${pkgs.fd}"
        export NIXCATS_BAT_PATH="${pkgs.bat}"
        export NIXCATS_EZA_PATH="${pkgs.eza}"

        # Determine config directory
        cfgdir="''${NIXCATS_FISH_DIR:-$XDG_CONFIG_HOME/nixCats-fish}"

        # Seed config if it doesn't exist
        if [ ! -d "$cfgdir" ]; then
          mkdir -p "$cfgdir"
          cp -r ${defaultConfig}/* "$cfgdir/"
        fi

        # Set Fish config path and launch
        export XDG_CONFIG_HOME="$(dirname "$cfgdir")"
        export FISHCAT_CONFIG_DIR="$cfgdir"
        exec ${pkgs.fish}/bin/fish --init-command="set -gx __fish_config_dir '$cfgdir'" "$@"
      '';

      # The launcher
      fishcat = pkgs.writeShellApplication {
        name = "fishcat";
        runtimeInputs = selected;
        text = ''
          exec ${wrapperScript} "$@"
        '';
      };
    in {
      package = fishcat;
      inherit pkgs;
    };

    mkHomeModule = system: {
      config,
      lib,
      ...
    }: let
      inherit (lib) mkEnableOption mkIf types;
      pkg = (mkPkg system).package;
    in {
      options.programs.nixCats-fish = {
        enable = mkEnableOption "Install nixCats-fish (fishcat)";
        setAsDefaultShell = lib.mkOption {
          type = types.bool;
          default = false;
          description = "Set login shell to fishcat (via chsh).";
        };
        seedConfig = lib.mkOption {
          type = types.bool;
          default = true;
          description = "Seed XDG config template on activation if missing.";
        };
      };

      config = mkIf config.programs.nixCats-fish.enable {
        home.packages = [pkg];

        # Optional seed via HM
        home.activation.nixCats-fish-init = mkIf config.programs.nixCats-fish.seedConfig (
          lib.hm.dag.entryAfter ["writeBoundary"] ''
            cfgdir="${config.home.homeDirectory}/.config/nixCats-fish"
            if [ ! -e "$cfgdir/config.fish" ]; then
              mkdir -p "$cfgdir"
              cp -r ${(mkPkg system).pkgs.runCommand "ncf-template" {} "cp -r ${./config} $out"}/config/* "$cfgdir" 2>/dev/null || true
            fi
          ''
        );
      };
    };

    mkNixosModule = system: {
      lib,
      config,
      pkgs,
      ...
    }: let
      inherit (lib) mkEnableOption mkIf;
    in {
      options.programs.nixCats-fish.enable = mkEnableOption "Install nixCats-fish (fishcat) system-wide";
      config = mkIf config.programs.nixCats-fish.enable {
        environment.systemPackages = [(mkPkg system).package];
      };
    };
  in {
    packages = forAllSystems (system: {
      default = (mkPkg system).package;
      nixCats-fish = (mkPkg system).package;
    });

    homeModules.default = mkHomeModule "x86_64-linux";
    nixosModules.default = mkNixosModule "x86_64-linux";
  };
}
