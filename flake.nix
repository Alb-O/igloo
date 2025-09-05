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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "x86_64-linux"
      ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    let
      # Shared pkgs configuration to avoid duplication
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = import ./home-manager/overlays { inherit inputs; };
          config.allowUnfree = true;
        };
    in
    {
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
      nixosConfigurations =
        let
          usersBase = import ./lib/users.nix;
          usersLocal =
            if builtins.pathExists ./lib/users.local.nix then import ./lib/users.local.nix else { };
          users = usersBase // usersLocal;
          primaryUser = if users ? primary then users.primary else users.default;
          hosts = import ./lib/hosts.nix;

          mkSystem =
            {
              userProfile,
              hostProfile,
              modules ? [ ],
            }:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs outputs;
                user = userProfile;
                host = hostProfile;
              };
              modules = modules;
            };

          desktopCfg = {
            userProfile = primaryUser;
            hostProfile = hosts.desktop;
            modules = [
              ./nixos/hosts/desktop/configuration.nix
            ]
            ++ (nixpkgs.lib.optionals (builtins.pathExists ./nixos/hosts/local.nix) [
              ./nixos/hosts/local.nix
            ]);
          };
          serverCfg = {
            userProfile = users.admin;
            hostProfile = hosts.server;
            modules = [
              ./nixos/hosts/server/configuration.nix
              nixos-wsl.nixosModules.wsl
            ]
            ++ (nixpkgs.lib.optionals (builtins.pathExists ./nixos/hosts/local.nix) [
              ./nixos/hosts/local.nix
            ]);
          };
        in
        {
          desktop = mkSystem desktopCfg;
          server = mkSystem serverCfg;
        };

      # Home Manager configurations
      homeConfigurations =
        let
          pkgs = pkgsFor "x86_64-linux";
          usersBase = import ./lib/users.nix;
          usersLocal =
            if builtins.pathExists ./lib/users.local.nix then import ./lib/users.local.nix else { };
          users = usersBase // usersLocal;
          hosts = import ./lib/hosts.nix;

          mkHome =
            name: userProfile: hostProfile:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inputs = inputs;
                outputs = self;
                user = userProfile;
                host = hostProfile;
              };
              modules = [
                ./home-manager/home.nix
              ];
            };
        in
        {
          "default@desktop" = mkHome "default@desktop" users.default hosts.desktop;
          "admin@server" = mkHome "admin@server" users.admin hosts.server;
        }
        // (nixpkgs.lib.optionalAttrs (users ? primary) (
          let
            u = users.primary;
          in
          {
            "${u.username}@desktop" = mkHome "${u.username}@desktop" u hosts.desktop;
            "${u.username}@server" = mkHome "${u.username}@server" u hosts.server;
          }
        ));

      # Export custom packages
      packages = forAllSystems (system: import ./home-manager/pkgs (pkgsFor system));
    };
}
