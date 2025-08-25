{
  description = "Dynamic NixOS configuration with environment-based secrets management";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Niri flake
    niri-flake.url = "github:sodiboo/niri-flake";

    # NixOS-WSL for Windows Subsystem for Linux support
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nixCats flake
    nixCats-nvim.url = "path:./flakes/nixCats-nvim";

    # Bash nixCats flake (ble.sh + XDG config)
    nixCats-bash.url = "path:./flakes/nixCats-bash";

    # Fish nixCats flake (modern Fish shell + fzf integration)
    nixCats-fish.url = "path:./flakes/nixCats-fish";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    niri-flake,
    nixos-wsl,
    nixCats-nvim,
    nixCats-bash,
    nixCats-fish,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in let
    # Shared pkgs configuration to avoid duplication
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = import ./home-manager/overlays {inherit inputs;};
        config.allowUnfree = true;
      };
  in {
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = {
      default = import ./nixos/modules;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#configuration-name'
    nixosConfigurations = let
      users = import ./lib/users.nix;
      hosts = import ./lib/hosts.nix;

      mkSystem = {
        userProfile,
        hostProfile,
        modules ? [],
      }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            globals = import ./lib/globals.nix {
              inherit userProfile hostProfile;
            };
          };
          modules = modules;
        };

      # Configuration mapping based on MACHINE_ID environment variable
      machineConfigs = {
        desktop = {
          userProfile = users.default;
          hostProfile = hosts.desktop;
          modules = [./nixos/hosts/desktop/configuration.nix];
        };
        server = {
          userProfile = users.admin;
          hostProfile = hosts.server;
          modules = [
            ./nixos/hosts/server/configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
        };
      };

      # Get current machine configuration
      machineId = let
        id = builtins.getEnv "MACHINE_ID";
      in
        if id != ""
        then id
        else "desktop";
      currentHostname = let
        h = builtins.getEnv "HOSTNAME";
      in
        if h != ""
        then h
        else "desktop";
      currentConfig = machineConfigs.${machineId} or machineConfigs.desktop;
    in ({
        # Generic configuration types for reference
        desktop = mkSystem machineConfigs.desktop;
        server = mkSystem machineConfigs.server;
      }
      // nixpkgs.lib.optionalAttrs (currentHostname != "desktop" && currentHostname != "server") {
        # Current hostname configuration (only if different from generic names)
        ${currentHostname} = mkSystem currentConfig;
      });

    # Home Manager configurations
    homeConfigurations = let
      # Load dynamic user configuration from .env file
      envConfig = import ./home-manager/lib/env-loader.nix;
      pkgs = pkgsFor "x86_64-linux";

      # User globals configuration
      homeGlobals = import ./home-manager/lib/globals.nix {
        inherit (envConfig) username;
        name = envConfig.fullName;
        email = envConfig.email;
        hostname = envConfig.hostname;
        # Disable graphical features in WSL
        isGraphical = !envConfig.isWSL;
      };
    in {
      # Primary configuration with user@hostname
      "${envConfig.username}@${envConfig.hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          outputs = self;
          globals = homeGlobals;
        };
        modules = [
          ./home-manager/home.nix
          niri-flake.homeModules.config
        ];
      };
    };

    # Export custom packages
    packages = forAllSystems (system: import ./home-manager/pkgs (pkgsFor system));

    # Optionally, add Cachix binary cache for claude-code
    nixConfig = {
      substituters = ["https://claude-code.cachix.org"];
      trusted-public-keys = ["claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="];
    };
  };
}
