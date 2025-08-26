{
pkgs,
...
}:
let
  neovim-nightly = (import (builtins.fetchTarball {
    url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  })) pkgs pkgs;
in
{
  programs.neovim = {
    enable = true;
    package = neovim-nightly.neovim;
    defaultEditor = true;
  };
}
