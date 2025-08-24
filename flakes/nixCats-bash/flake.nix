{
  description = "nixCats-bash: ble.sh-powered Bash with editable XDG config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPkg = system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

          # Categories for optional runtime deps (can be extended)
          categories = {
            core = with pkgs; [ bashInteractive bash-completion ];
            nav = with pkgs; [ zoxide ];
            fzf = with pkgs; [ fzf ];
            env = with pkgs; [ direnv ];
            blesh = with pkgs; [ blesh ];
          };

          # Merge selected categories — simple, readable approach
          selected = builtins.concatLists [
            categories.core
            categories.blesh
            categories.fzf
            categories.env
            categories.nav
          ];

          initTemplate = pkgs.writeText "nixCats-bash-init.bash"
            (pkgs.lib.replaceStrings ["@FZF@" "@BLESH@"]
              ["${pkgs.fzf}" "${pkgs.blesh}"]
              (builtins.readFile ./rc/init.bash)
            );

          # Default, read-only init in store for fallback use only
          defaultInit = initTemplate;

          # The rcfile that the wrapper passes to bash.
          # Runtime resolution:
          # - if $NIXCATS_BASH_DIR/init.bash exists, source it (editable in your checkout)
          # - else if $XDG_CONFIG_HOME/nixCats-bash/init.bash exists, source it (user-managed)
          # - else: source the built-in default (read-only) from the store
          wrapperRc = pkgs.writeText "nixCats-bash-rc" ''
            : "''${XDG_CONFIG_HOME:=$HOME/.config}"
            : "''${XDG_STATE_HOME:=$HOME/.local/state}"
            # Provide package paths for user config to reference without rebuilds
            export NIXCATS_FZF_SHARE="${pkgs.fzf}/share/fzf"
            export NIXCATS_BLESH_DIR="${pkgs.blesh}/share/blesh"
            cfgdir="''${NIXCATS_BASH_DIR:-$XDG_CONFIG_HOME/nixCats-bash}"
            if [ -r "$cfgdir/init.bash" ]; then
              . "$cfgdir/init.bash"
            elif [ -r "$XDG_CONFIG_HOME/nixCats-bash/init.bash" ]; then
              . "$XDG_CONFIG_HOME/nixCats-bash/init.bash"
            else
              . ${defaultInit}
            fi
          '';

          # The launcher that ensures interactive Bash uses our rc wrapper
          bashcat = pkgs.writeShellApplication {
            name = "bashcat";
            runtimeInputs = selected;
            text = ''
              exec ${pkgs.bashInteractive}/bin/bash --noprofile --rcfile ${wrapperRc} -i "$@"
            '';
          };
        in {
          package = bashcat;
          inherit pkgs;
        };

      mkHomeModule = system:
        { config, lib, ... }:
        let
          inherit (lib) mkEnableOption mkIf types;
          pkg = (mkPkg system).package;
        in {
          options.programs.nixCats-bash = {
            enable = mkEnableOption "Install nixCats-bash (bashcat)";
            setAsDefaultShell = lib.mkOption {
              type = types.bool;
              default = false;
              description = "Set login shell to bashcat (via chsh).";
            };
            seedConfig = lib.mkOption {
              type = types.bool;
              default = true;
              description = "Seed XDG config template on activation if missing.";
            };
          };

          config = mkIf config.programs.nixCats-bash.enable {
            home.packages = [ pkg ];

            # Optional seed via HM (wrapper already seeds on first run; this is just explicit)
            home.activation.nixCats-bash-init = mkIf config.programs.nixCats-bash.seedConfig (
              lib.hm.dag.entryAfter ["writeBoundary"] ''
                cfgdir="${config.home.homeDirectory}/.config/nixCats-bash"
                if [ ! -e "$cfgdir/init.bash" ]; then
                  mkdir -p "$cfgdir"
                  cp -r ${ (mkPkg system).pkgs.runCommand "ncb-template" {} "cp -r ${./rc} $out" }/rc/* "$cfgdir" 2>/dev/null || true
                fi
              ''
            );
          };
        };

      mkNixosModule = system:
        { lib, config, pkgs, ... }:
        let inherit (lib) mkEnableOption mkIf; in {
          options.programs.nixCats-bash.enable = mkEnableOption "Install nixCats-bash (bashcat) system-wide";
          config = mkIf config.programs.nixCats-bash.enable {
            environment.systemPackages = [ (mkPkg system).package ];
          };
        };
    in {
      packages = forAllSystems (system: {
        default = (mkPkg system).package;
        nixCats-bash = (mkPkg system).package;
      });

      homeModules.default = mkHomeModule "x86_64-linux";
      nixosModules.default = mkNixosModule "x86_64-linux";
    };
}
