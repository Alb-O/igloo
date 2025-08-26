{
  description = "Neovim module with nightly overlay";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeManagerModules.default = { config, pkgs, lib, ... }: {
        # Apply neovim nightly overlay
        nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];

        # Configure neovim
        programs.neovim = {
          enable = true;
          package = pkgs.neovim;
          defaultEditor = true;
        };
      };
    };
}