# Niri Wayland Compositor Configuration
# Self-contained module using sub-flake
let
  niri-module = (import ./flake.nix).outputs {
    self = null;
    nixpkgs = import <nixpkgs> {};
    niri = builtins.getFlake "github:sodiboo/niri-flake";
  };
in
niri-module.homeManagerModules.default
