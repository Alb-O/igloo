-- GitHub Copilot Plugins
require('mini.deps').add({
  source = 'zbirenbaum/copilot.lua'
})

require('mini.deps').add({
  source = 'zbirenbaum/copilot-cmp',
  depends = { 'zbirenbaum/copilot.lua' }
})

require('mini.deps').later(function()
  require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
  
  require("copilot_cmp").setup()
end)
