{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Import neovim-nightly overlay for this module
  nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlays.default];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Use nightly neovim from overlay
    package = pkgs.neovim;

    extraLuaConfig = builtins.readFile ./init.lua;

    extraPackages = with pkgs; [
      # Language servers
      lua-language-server

      # Additional tools that might be needed
      ripgrep
      fd
    ];
  };

  # Copy Lua configuration files to the right location
  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  # Copy LSP configuration files
  xdg.configFile."nvim/lsp" = {
    source = ./lsp;
    recursive = true;
  };

  # Install nvimpager
  home.packages = with pkgs; [
    nvimpager
  ];

  # Configure nvimpager with colorscheme only
  xdg.configFile."nvimpager/init.lua".text = builtins.readFile ./lua/config/colorscheme.lua;
}
