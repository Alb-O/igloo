-- autocmd
--------------------------------------------------------------------------------
-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Simple cursor color override after colorscheme loads
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Set custom cursor colors after colorscheme loads',
  group = vim.api.nvim_create_augroup('cursor-colors', { clear = true }),
  callback = function()
    vim.cmd[[highlight Cursor guifg=#82AAFF guibg=#82AAFF]]
    vim.cmd[[highlight iCursor guifg=#82AAFF guibg=#82AAFF]]
    vim.opt.guicursor = 'n-v-c:block-Cursor,i-ci-ve:ver25-iCursor-blinkwait300-blinkon200-blinkoff150'
  end,
})
