-- Plugins for previewing text and files

-- Markview for markdown previewing
require('mini.deps').add({
  source = 'OXY2DEV/markview.nvim',
})

require('markview').setup({
  preview = {
    icon_provider = "mini",
  }
})
