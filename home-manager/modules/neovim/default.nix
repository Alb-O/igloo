{
  config,
  pkgs,
  globals,
  ...
}: {
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

      -- Setup default colorscheme
      vim.cmd[[colorscheme vscode]]

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
