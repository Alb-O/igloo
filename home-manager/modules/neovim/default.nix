# Neovim Configuration
# Self-contained module using sub-flake for nightly overlay
let
  neovim-module = (import ./flake.nix).outputs {
    self = null;
    nixpkgs = import <nixpkgs> {};
    neovim-nightly-overlay = builtins.getFlake "github:nix-community/neovim-nightly-overlay";
  };
in
neovim-module.homeManagerModules.default
