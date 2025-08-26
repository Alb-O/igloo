{
  description = "Niri module with self-contained dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    niri,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeManagerModules.default = {
      config,
      pkgs,
      globals,
      lib,
      ...
    }: let
      # Import modular configurations
      inputConfig = import ./input.nix;
      outputsConfig = import ./outputs.nix;
      layoutConfig = import ./layout.nix {};
      bindsConfig = import ./binds.nix {
        inherit config pkgs globals;
      };
      windowRulesConfig = import ./window-rules.nix;
      miscConfig = import ./misc.nix;
    in {
      # Import niri home-manager modules
      imports = [
        niri.homeModules.niri
      ];

      # Enable binary cache for niri
      nix.settings = {
        substituters = lib.mkAfter ["https://niri.cachix.org"];
        trusted-public-keys = lib.mkAfter ["niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl5me6UKLqjlUKjpj9EQ="];
      };

      # Apply niri overlay
      nixpkgs.overlays = [niri.overlays.niri];

      # Configure niri
      programs.niri = {
        enable = true;
        package = pkgs.niri-stable; # Available after overlay is applied
        settings =
          inputConfig // outputsConfig // layoutConfig // bindsConfig // windowRulesConfig // miscConfig;
      };
    };
  };
}
