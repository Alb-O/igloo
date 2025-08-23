-- Autocomplete and snippets

require('mini.deps').add({
  source = 'hrsh7th/nvim-cmp',
  depends = {
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'echasnovski/mini.snippets',
    'abeldekat/cmp-mini-snippets'
  }
})

require('mini.deps').later(function()
  -- Set up nvim-cmp
  local cmp = require('cmp')

  -- Define kind icons
  local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
    Copilot = "",
  }

  cmp.setup({
    snippet = {
      expand = function(args)
        -- For mini.snippets users
        local insert = require('mini.snippets').default_insert
        insert({ body = args.body })
      end,
    },
    window = {
      completion = {
        border = 'none',
        winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
      },
      documentation = {
        border = 'none',
      },
    },
    view = {
      entries = { name = 'custom', selection_order = 'near_cursor' }
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    formatting = {
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
        -- Source
        vim_item.menu = ({
          buffer = "Buffer",
          nvim_lsp = "LSP",
          mini_snippets = "Snippet",
          path = "Path",
          cmdline = "CMD",
          copilot = "Copilot",
        })[entry.source.name]
        return vim_item
      end
    },
    sources = cmp.config.sources({
      { name = 'copilot',       group_index = 2 },
      { name = 'nvim_lsp',      group_index = 2 },
      { name = 'mini_snippets', group_index = 2 },
    }, {
      { name = 'buffer' },
    }),
    sorting = {
      priority_weight = 2,
      comparators = {
        require("copilot_cmp.comparators").prioritize,
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    }
  })

  -- Use buffer source for `/` and `?`
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for `:`
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig with nvim-cmp capabilities
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Update the existing lua_ls setup with capabilities
  vim.lsp.config.lua_ls = vim.tbl_deep_extend('force', vim.lsp.config.lua_ls or {}, {
    capabilities = capabilities
  })

  -- Set up custom highlights
  vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#A377BF", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#6C8ED4", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#7E8294", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#9FBD73", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#B5585F", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#D4A959", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644", bg = "NONE" })
end)
