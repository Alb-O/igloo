-- Treesitter configuration
require('mini.deps').add({
  source = 'nvim-treesitter/nvim-treesitter',
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'nix', 'markdown' },
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})