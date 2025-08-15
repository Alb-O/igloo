{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./languages
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      set number relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set incsearch
      set hlsearch
      set scrolloff=8
      set signcolumn=yes
      set updatetime=50
      set termguicolors
      let mapleader = " "
    '';

    extraPackages = with pkgs; [
      # Tools needed by plugins
      ripgrep
      fd

      # Copilot
      luajitPackages.tiktoken_core
      lynx
      gnumake
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          # Essential plugins
          plenary-nvim
          nvim-web-devicons
          snacks-nvim

          # Colorschemes
          catppuccin-nvim
          vscode-nvim

          # Treesitter
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects

          # LSP and completion
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip

          nvim-tree-lua # File explorer
          lualine-nvim # Status line
          gitsigns-nvim # Git integration
          indent-blankline-nvim # Indentation guides
          nvim-autopairs # Auto pairs
          comment-nvim # Comment toggling
          toggleterm-nvim # Terminal management
          hmts-nvim # Nix string highlighting with treesitter
        ];
        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        -- Set the dev path for Lazy to find Nix plugins
        vim.env.LAZY_DEV_PATH = "${lazyPath}"

        -- Load the main Lazy configuration
        ${builtins.readFile ./lazy-config.lua}
      '';
  };

  # Treesitter parsers managed by Nix
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths =
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (
            plugins: with plugins; [
              bash
              c
              cpp
              css
              go
              html
              javascript
              json
              lua
              markdown
              nix
              python
              rust
              toml
              typescript
              vim
              vimdoc
              yaml
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";
}
