-- Colorscheme

require('mini.deps').add('folke/tokyonight.nvim')

require('mini.deps').later(function()
  vim.cmd[[colorscheme tokyonight-night]]
end)