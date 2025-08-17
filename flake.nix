{
  description = "Igloo Home Manager";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    # Additional inputs needed by existing config
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    niri-flake.url = "github:sodiboo/niri-flake";
    nix-colors.url = "github:misterio77/nix-colors";
    nix-userstyles.url = "github:knoopx/nix-userstyles";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      nix-vscode-extensions,
      niri-flake,
      nix-colors,
      nix-userstyles,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Load dynamic user configuration from .env file
      envConfig = import ./lib/env-loader.nix;
      username = envConfig.username;
      hostname = envConfig.hostname;
      name = envConfig.fullName;
      email = envConfig.email;

      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays { inherit inputs; };
        config.allowUnfree = true;
      };

      # User globals using the proper lib
      globals = import ./lib/globals.nix {
        inherit
          username
          name
          email
          hostname
          ;
        isGraphical = true;
      };
    in
    {
      homeConfigurations."${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs;
          outputs = self;
          inherit globals;
        };

        modules = [
          ./home.nix
          niri-flake.homeModules.config
        ];
      };

      # Also create a simple configuration for easier switching
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs;
          outputs = self;
          inherit globals;
        };

        modules = [
          ./home.nix
          niri-flake.homeModules.config
        ];
      };
    };
}
