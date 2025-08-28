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

    # NixOS-WSL for Windows Subsystem for Linux support
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    
    # Single source of environment configuration
    env = import ./lib/env.nix;
    
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
            inherit inputs outputs env;
            globals = import ./lib/globals.nix {
              inherit env userProfile hostProfile;
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
      currentConfig = machineConfigs.${env.machineId} or machineConfigs.desktop;
    in ({
        # Generic configuration types for reference
        desktop = mkSystem machineConfigs.desktop;
        server = mkSystem machineConfigs.server;
      }
      // nixpkgs.lib.optionalAttrs (env.hostname != "desktop" && env.hostname != "server") {
        # Current hostname configuration (only if different from generic names)
        ${env.hostname} = mkSystem currentConfig;
      });

    # Home Manager configurations
    homeConfigurations = let
      pkgs = pkgsFor "x86_64-linux";

      # User globals configuration
      homeGlobals = import ./home-manager/lib/globals.nix {
        inherit env;
      };
    in {
      # Primary configuration with user@hostname
      "${env.username}@${env.hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs env;
          outputs = self;
          globals = homeGlobals;
        };
        modules = [
          ./home-manager/home.nix
        ];
      };
    };

    # Export custom packages
    packages = forAllSystems (system: import ./home-manager/pkgs (pkgsFor system));
  };
}
