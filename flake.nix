{
  description = "NixOS + Home Manager configuration";

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

    kakkle.url = "git+https://github.com/Alb-O/kakkle?submodules=1";

    www.url = "github:Alb-O/aflake.www";
    www.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      kakkle,
      www,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = import ./hm/overlays { inherit inputs; };
          config.allowUnfree = true;
        };

      defaultUser = {
        username = "user";
        name = "Example User";
        email = "user@example.com";
        homeDirectory = "/home/user";
      };

      defaultDesktopHost = {
        hostname = "desktop";
        stateVersion = "24.11";
        isGraphical = true;
        architecture = "x86_64-linux";
        profile = "desktop";
        timeZone = "Etc/UTC";
        locale = "en_US.UTF-8";
        extraGroups = [
          "seat"
          "networkmanager"
          "audio"
          "video"
          "docker"
        ];
        extraLocales = [ "en_AU.UTF-8/UTF-8" ];
      };

      defaultServerHost = {
        hostname = "server";
        stateVersion = "24.11";
        isGraphical = false;
        architecture = "x86_64-linux";
        profile = "server";
        timeZone = "Etc/UTC";
        locale = "en_US.UTF-8";
        extraGroups = [
          "networkmanager"
          "docker"
          "systemd-journal"
        ];
        extraLocales = [ "en_AU.UTF-8/UTF-8" ];
      };

      personalOverridesPath = ./overrides/personal.nix;
      personal =
        if builtins.pathExists personalOverridesPath then
          import personalOverridesPath
        else
          { };

      activeUser = defaultUser // (personal.user or { });
      activeDesktopHost = defaultDesktopHost // (personal.desktopHost or { });
      activeServerHost = defaultServerHost // (personal.serverHost or { });

      mkSystem =
        {
          userProfile,
          hostProfile,
          modules,
        }:
        nixpkgs.lib.nixosSystem {
          system = hostProfile.architecture;
          specialArgs = {
            inherit inputs outputs;
            user = userProfile;
            host = hostProfile;
          };
          modules = modules;
        };

      mkHome =
        name: userProfile: hostProfile:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor hostProfile.architecture;
          extraSpecialArgs = {
            inputs = inputs;
            outputs = self;
            user = userProfile;
            host = hostProfile;
          };
          modules = [
            ./hm/home.nix
          ];
        };
    in
    {
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = {
        default = import ./sys/mod;
      };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#configuration-name'
      nixosConfigurations = {
        desktop =
          mkSystem {
            userProfile = activeUser;
            hostProfile = activeDesktopHost;
            modules =
              [
                ./sys/hosts/desktop/configuration.nix
              ]
              ++ (nixpkgs.lib.optionals (builtins.pathExists ./sys/hosts/local.nix) [
                ./sys/hosts/local.nix
              ]);
          };

        server =
          mkSystem {
            userProfile = activeUser;
            hostProfile = activeServerHost;
            modules =
              [
                ./sys/hosts/server/configuration.nix
                nixos-wsl.nixosModules.wsl
              ]
              ++ (nixpkgs.lib.optionals (builtins.pathExists ./sys/hosts/local.nix) [
                ./sys/hosts/local.nix
              ]);
          };
      };

      homeConfigurations = {
        "${activeUser.username}@${activeDesktopHost.hostname}" =
          mkHome "${activeUser.username}@${activeDesktopHost.hostname}" activeUser activeDesktopHost;
      };
    };
  nixConfig = {
    warn-dirty = false;
  };
}
