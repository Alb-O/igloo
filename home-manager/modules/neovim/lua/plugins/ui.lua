-- UI and appearance related mini modules
require('mini.statusline').setup()
require('mini.icons').setup()
require('mini.cursorword').setup()
require('mini.trailspace').setup()
require('mini.indentscope').setup({
  symbol = "│",
  options = { try_as_border = true },
})