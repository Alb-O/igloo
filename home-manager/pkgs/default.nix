# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  blender-daily = pkgs.callPackage ./blender-daily.nix {};
  tmux-fzf-tools = pkgs.callPackage ./tmux-fzf-tools.nix {};
  opencode-bin = pkgs.callPackage ./opencode-bin.nix {};
  opencode-src = pkgs.callPackage ./opencode-src.nix {};
  file-preview = pkgs.callPackage ./file-preview.nix {};

}
