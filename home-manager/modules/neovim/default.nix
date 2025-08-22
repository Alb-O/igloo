{
  config,
  pkgs,
  globals,
  ...
}: let
  colors = import ../../lib/themes globals;
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true

      -- Set leader key
      vim.g.mapleader = " "

      -- Add plugins using vim.pack
      vim.pack.add({ "https://github.com/Mofiqul/vscode.nvim" })
      vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

      -- Setup colorscheme
      vim.cmd[[colorscheme vscode]]
      
      -- Override UI elements with theme colors while preserving syntax highlighting
      vim.cmd[[
        " Set transparent background
        highlight Normal guibg=NONE ctermbg=NONE
        highlight NonText guibg=NONE ctermbg=NONE
        highlight SignColumn guibg=NONE ctermbg=NONE
        highlight NormalFloat guibg=NONE ctermbg=NONE
        
        " UI elements using theme colors
        highlight LineNr guifg=${colors.ui.border.primary} guibg=NONE
        highlight CursorLineNr guifg=${colors.ui.foreground.primary} guibg=NONE
        highlight StatusLine guifg=${colors.ui.foreground.onPrimary} guibg=${colors.palette.primary}
        highlight StatusLineNC guifg=${colors.ui.foreground.secondary} guibg=${colors.ui.background.tertiary}
        highlight VertSplit guifg=${colors.ui.border.primary} guibg=NONE
        highlight WinSeparator guifg=${colors.ui.border.primary} guibg=NONE
        highlight TabLine guifg=${colors.ui.foreground.secondary} guibg=${colors.ui.background.tertiary}
        highlight TabLineFill guibg=${colors.ui.background.primary}
        highlight TabLineSel guifg=${colors.ui.foreground.primary} guibg=${colors.ui.background.secondary}
        highlight Pmenu guifg=${colors.ui.foreground.primary} guibg=${colors.ui.background.secondary}
        highlight PmenuSel guifg=${colors.ui.foreground.primary} guibg=${colors.ui.special.selection}
        highlight PmenuSbar guibg=${colors.ui.background.tertiary}
        highlight PmenuThumb guibg=${colors.ui.border.primary}
        highlight Visual guifg=${colors.ui.foreground.onPrimary} guibg=${colors.palette.primary}
        highlight Search guifg=${colors.ui.background.primary} guibg=${colors.ui.special.highlight}
        highlight IncSearch guifg=${colors.ui.background.primary} guibg=${colors.ui.interactive.accent}
        highlight CursorLine guibg=${colors.ui.special.hover}
        highlight ColorColumn guibg=${colors.ui.background.tertiary}
        highlight Folded guifg=${colors.ui.foreground.tertiary} guibg=${colors.ui.background.tertiary}
        highlight FoldColumn guifg=${colors.ui.foreground.tertiary} guibg=NONE
        highlight MatchParen guifg=${colors.ui.interactive.primary} guibg=${colors.ui.special.hover}
        highlight ErrorMsg guifg=${colors.ui.status.error} guibg=NONE
        highlight WarningMsg guifg=${colors.ui.status.warning} guibg=NONE
        highlight ModeMsg guifg=${colors.ui.foreground.primary} guibg=NONE
        highlight MoreMsg guifg=${colors.ui.status.info} guibg=NONE
        highlight Question guifg=${colors.ui.status.info} guibg=NONE
        highlight Directory guifg=${colors.ui.interactive.secondary} guibg=NONE
        highlight Title guifg=${colors.ui.interactive.primary} guibg=NONE
        highlight WildMenu guifg=${colors.ui.foreground.primary} guibg=${colors.ui.special.selection}
      ]]

      -- Custom FZF picker functions
      local fzf_files = dofile('${./scripts/fzf-files.lua}')
      local fzf_grep = dofile('${./scripts/fzf-grep.lua}')

      -- Basic keymaps
      vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
      vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
      vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlights" })
      vim.keymap.set("n", "<leader>ff", fzf_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", fzf_grep, { desc = "Live grep" })
    '';
  };
}
