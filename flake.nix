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

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # Niri flake for advanced configuration
    niri-flake.url = "github:sodiboo/niri-flake";

    # nix-colors for color scheme management
    nix-colors.url = "github:misterio77/nix-colors";

    # nix-userstyles for website theming
    nix-userstyles.url = "github:knoopx/nix-userstyles";

    # NixOS-WSL for Windows Subsystem for Linux support
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nightly overlay
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    niri-flake,
    nix-colors,
    nix-userstyles,
    nixos-wsl,
    neovim-nightly-overlay,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];

    # Load bootstrap system for dynamic user configuration
    bootstrap = import ./lib/bootstrap.nix;

    # Generate user configurations inline
    users =
      {
        nixos = {
          name =
            if bootstrap.env.USERNAME == "nixos"
            then bootstrap.env.NAME
            else "NixOS User";
          email =
            if bootstrap.env.USERNAME == "nixos"
            then bootstrap.env.EMAIL
            else "nixos@example.com";
          username = "nixos";
          isGraphical = false; # WSL environment without graphics
        };
      }
      // (
        if bootstrap.env.USERNAME != "nixos"
        then {
          "${bootstrap.env.USERNAME}" = {
            name = bootstrap.env.NAME;
            email = bootstrap.env.EMAIL;
            username = bootstrap.env.USERNAME;
          };
        }
        else {}
      );

    # Helper function to create home configuration
    mkHomeConfiguration = {
      username ? bootstrap.env.USERNAME,
      name ? bootstrap.env.NAME,
      email ? bootstrap.env.EMAIL,
      hostname ? bootstrap.env.HOSTNAME,
      system ? "x86_64-linux",
      isGraphical ? true, # Most systems have graphics, WSL is the exception
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./overlays {inherit inputs;};
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit inputs outputs;
          globals = import ./lib/globals.nix {
            inherit
              username
              hostname
              isGraphical
              name
              email
              ;
          };
        };
        modules =
          [
            ./home-manager/home.nix
          ]
          ++ (
            # Only include niri module for graphical systems
            if isGraphical
            then [
              niri-flake.homeModules.config
            ]
            else []
          );
      };
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = {
      default = final: prev:
        builtins.foldl' (acc: overlay: acc // (overlay final prev)) {} (
          import ./overlays {inherit inputs;}
        );
    };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = {
      default = import ./nixos/modules;
    };
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = {
      default = import ./home-manager/modules;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = let
      # Create dynamic config only when not in flake check mode
      isFlakeCheck = (builtins.getEnv "PWD") == "/" || (builtins.getEnv "PWD") == "";

      dynamicConfig =
        if isFlakeCheck
        then {}
        else {
          "${bootstrap.env.HOSTNAME}" = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs;
              globals = import ./lib/globals.nix {
                inherit (users."${bootstrap.env.USERNAME}") username name email;
                hostname = bootstrap.env.HOSTNAME;
              };
            };
            modules = [./nixos/hosts/${bootstrap.env.MACHINE_ID or bootstrap.env.HOSTNAME}/configuration.nix];
          };
        };
    in
      dynamicConfig
      // {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            # Use bootstrap values for consistent configuration
            globals = import ./lib/globals.nix {
              username = "nixos";
              name = bootstrap.env.NAME;
              email = bootstrap.env.EMAIL;
              hostname = "nixos";
              stateVersion = "24.11";
              isGraphical = false; # WSL environment
            };
          };
          modules = [
            # NixOS-WSL configuration
            ./nixos/hosts/nixos/configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
        };
      };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = let
      mkConfigs = hostname:
        nixpkgs.lib.mapAttrs' (
          userKey: userConfig:
            nixpkgs.lib.nameValuePair "${userConfig.username}@${hostname}" (mkHomeConfiguration {
              inherit (userConfig) username name email;
              inherit hostname;
              isGraphical = userConfig.isGraphical or true;
            })
        )
        users;
    in
      # Dynamic hostname from env + static nixos
      (mkConfigs bootstrap.env.HOSTNAME) // (mkConfigs "nixos");
    # Optionally, add Cachix binary cache for claude-code
    nixConfig = {
      substituters = ["https://claude-code.cachix.org"];
      trusted-public-keys = ["claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="];
    };
  };
}
