# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  blender-daily = pkgs.callPackage ./blender-daily.nix {};
  opencode-bin = pkgs.callPackage ./opencode-bin.nix {};
  opencode-src = pkgs.callPackage ./opencode-src.nix {};
  setup-background-terminals = pkgs.callPackage ./setup-background-terminals.nix {};
}
