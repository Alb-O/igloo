require("lazy").setup({
  defaults = {
    lazy = false, -- Don't lazy load - load everything at startup
  },
  dev = {
    -- reuse files from pkgs.vimPlugins.*
    path = os.getenv("LAZY_DEV_PATH") or vim.fn.stdpath("data") .. "/lazy-dev",
    patterns = { "" },
    -- fallback to download
    fallback = true,
  },
  spec = {
    -- ===== COLORSCHEMES =====
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          flavour = "mocha",
          background = {
            light = "latte",
            dark = "mocha",
          },
        })
      end,
    },
    {
      "Mofiqul/vscode.nvim",
      priority = 1000,
      config = function()
        require('vscode').setup({
          transparent = false,
          italic_comments = true,
          italic_inlayhints = true,
          underline_links = true,
          disable_nvimtree_bg = true,
          terminal_colors = true,
        })
        vim.cmd.colorscheme("vscode")
      end,
    },

    -- ===== ESSENTIAL DEPENDENCIES =====
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons" },

    -- ===== SYNTAX HIGHLIGHTING =====
    {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require("nvim-treesitter.configs").setup({
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
    {
      "calops/hmts.nvim",
      config = function()
        -- hmts.nvim works out of the box, no setup required
      end,
    },

    -- ===== LSP & COMPLETION =====
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        lspconfig.rust_analyzer.setup({
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                enable = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              procMacro = {
                enable = true,
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "never",
                },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "never",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        })

        vim.lsp.inlay_hint.enable(true)
      end,
    },
    -- Completion plugins
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },

    -- ===== FILE MANAGEMENT =====
    {
      "nvim-tree/nvim-tree.lua",
      config = function()
        require("nvim-tree").setup()
      end,
      keys = {
        { "<leader>e", ":NvimTreeToggle<CR>", desc = "Toggle file explorer" },
      },
    },
    {
      "dmtrKovalenko/fff.nvim",
      lazy = false,
      build = "nix run .#release",
      config = function()
        local ok, fff = pcall(require, "fff")
        if not ok then
          vim.notify("fff.nvim failed to load: " .. fff, vim.log.levels.ERROR)
          return
        end

        local setup_ok, err = pcall(fff.setup, {
          base_path = vim.fn.getcwd(),
          max_results = 100,
          max_threads = 4,
          prompt = "🪿 ",
          title = "FFF Files",
          ui_enabled = true,
          width = 0.8,
          height = 0.8,
          preview = {
            enabled = true,
            width = 0.5,
            max_lines = 5000,
            max_size = 10 * 1024 * 1024,
            line_numbers = false,
            wrap_lines = false,
            show_file_info = true,
          },
          keymaps = {
            close = "<Esc>",
            select = "<CR>",
            select_split = "<C-s>",
            select_vsplit = "<C-v>",
            select_tab = "<C-t>",
            move_up = { "<Up>", "<C-p>" },
            move_down = { "<Down>", "<C-n>" },
          },
          frecency = {
            enabled = true,
            db_path = vim.fn.stdpath("cache") .. "/fff_nvim",
          },
        })

        if not setup_ok then
          vim.notify("fff.nvim setup failed: " .. err, vim.log.levels.ERROR)
          return
        end

        vim.notify("fff.nvim loaded successfully", vim.log.levels.INFO)
      end,
      keys = {
        {
          "<leader>ff",
          function()
            local ok, fff = pcall(require, "fff")
            if ok then
              fff.find_files()
            else
              vim.notify("fff.nvim not available", vim.log.levels.WARN)
            end
          end,
          desc = "Find files with FFF",
        },
      },
    },

    -- ===== UI ENHANCEMENTS =====
    {
      "nvim-lualine/lualine.nvim",
      config = function()
        require("lualine").setup({
          options = {
            theme = "vscode",
          },
        })
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require("ibl").setup()
      end,
    },

    -- ===== WINDOW MANAGEMENT =====
    {
      'mrjones2014/smart-splits.nvim',
      config = function()
        require('smart-splits').setup()
      end,
      keys = {
        -- Resizing splits
        { '<A-h>', function() require('smart-splits').resize_left() end, desc = "Resize split left" },
        { '<A-j>', function() require('smart-splits').resize_down() end, desc = "Resize split down" },
        { '<A-k>', function() require('smart-splits').resize_up() end, desc = "Resize split up" },
        { '<A-l>', function() require('smart-splits').resize_right() end, desc = "Resize split right" },
        -- Moving between splits
        { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = "Move to left split" },
        { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = "Move to bottom split" },
        { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = "Move to top split" },
        { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = "Move to right split" },
        { '<C-\\>', function() require('smart-splits').move_cursor_previous() end, desc = "Move to previous split" },
        -- Swapping buffers between windows
        { '<leader><leader>h', function() require('smart-splits').swap_buf_left() end, desc = "Swap buffer left" },
        { '<leader><leader>j', function() require('smart-splits').swap_buf_down() end, desc = "Swap buffer down" },
        { '<leader><leader>k', function() require('smart-splits').swap_buf_up() end, desc = "Swap buffer up" },
        { '<leader><leader>l', function() require('smart-splits').swap_buf_right() end, desc = "Swap buffer right" },
        -- Terminal mode mappings (ESC passes through to terminal programs)
        { "<C-\\>", "<C-\\><C-n>", mode = "t", desc = "Exit terminal mode" },
        { "<C-h>", "<C-\\><C-n><C-w>h", mode = "t", desc = "Move to left window from terminal" },
        { "<C-j>", "<C-\\><C-n><C-w>j", mode = "t", desc = "Move to bottom window from terminal" },
        { "<C-k>", "<C-\\><C-n><C-w>k", mode = "t", desc = "Move to top window from terminal" },
        { "<C-l>", "<C-\\><C-n><C-w>l", mode = "t", desc = "Move to right window from terminal" },
      },
    },

    -- ===== GIT INTEGRATION =====
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup()
      end,
    },

    -- ===== EDITING ENHANCEMENTS =====
    {
      "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup()
      end,
    },
    {
      "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup()
      end,
    },

    -- ===== AI ASSISTANCE =====
    {
      "github/copilot.vim",
      lazy = false,
    },
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "nvim-lua/plenary.nvim", branch = "master" },
      },
      build = "make tiktoken",
      opts = {},
    },

    -- ===== MARKDOWN =====
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      opts = {},
    },

    -- ===== TERMINAL MANAGEMENT =====
    {
      "akinsho/toggleterm.nvim",
      config = function()
        require("toggleterm").setup({
          size = 20,
          open_mapping = false,
          hide_numbers = true,
          shade_terminals = true,
          start_in_insert = true,
          insert_mappings = true,
          persist_size = true,
          direction = "horizontal",
          close_on_exit = false,
          shell = vim.o.shell,
        })
      end,
      keys = {
        { "<leader>to", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", desc = "Vertical terminal" },
        { "<leader>tt", "<cmd>ToggleTerm direction=tab<CR>", desc = "Terminal in new tab" },
      },
    },

    -- ===== QUALITY OF LIFE =====
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      config = function()
        require("snacks").setup({
          bigfile = { enabled = true },
          dashboard = { 
            enabled = true,
            width = 100,
            preset = {
              keys = {
                { key = "f", desc = "Find File", action = function()
                  local ok, fff = pcall(require, "fff")
                  if ok then
                    fff.find_files()
                  else
                    vim.notify("fff.nvim not available", vim.log.levels.WARN)
                  end
                end },
                { key = "n", desc = "New File", action = ":ene | startinsert" },
                { key = "g", desc = "Find Text", action = function()
                  local ok, fff = pcall(require, "fff")
                  if ok then
                    fff.find_files({ search_text = true })
                  else
                    vim.cmd("Telescope live_grep")
                  end
                end },
                { key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                { key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                { key = "s", desc = "Restore Session", section = "session" },
                { key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                { key = "q", desc = "Quit", action = ":qa" },
              },
              header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
            },
            sections = {
              { section = "header" },
              { section = "keys", gap = 1, padding = 1 },
              { pane = 2, title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
              { pane = 2, title = "Projects", section = "projects", indent = 2, padding = 1 },
              {
                pane = 2,
                title = "Git Status",
                section = "terminal",
                enabled = function()
                  return vim.fn.isdirectory('.git') == 1
                end,
                cmd = "git status --short --branch --renames",
                height = 5,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
              },
              { section = "startup" },
            },
          },
          indent = { enabled = true },
          input = { enabled = true },
          notifier = { enabled = true },
          quickfile = { enabled = true },
          statuscolumn = { enabled = true },
          words = { enabled = true },
        })
      end,
    },
  },
})

-- ===== COMPLETION SETUP =====
-- Setup completion after all plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
})
