-- Plugin manager setup
vim.pack.add({
  {
    src = "https://github.com/echasnovski/mini.nvim",
    version = "main",
  },
})

-- Set up mini.deps to manage other plugins
require('mini.deps').setup()

-- Load plugin configurations by category
require('plugins.colorscheme')
require('plugins.treesitter')
require('plugins.ui')
require('plugins.editing')
require('plugins.navigation')
require('plugins.preview')
require('plugins.copilot')
require('plugins.nvim-cmp')
