local plugins = {
  {
      "benlubas/molten-nvim",
      dependencies = { "3rd/image.nvim" },
      build = ":UpdateRemotePlugins",
      init = function()
          -- these are examples, not defaults. Please see the readme
          vim.g.molten_image_provider = "image.nvim"
          vim.g.molten_output_win_max_height = 20
      end,
  },
  -- {
  --   -- see the image.nvim readme for more information about configuring this plugin
  --   "3rd/image.nvim",
  --   opts = {
  --     backend = "kitty", -- whatever backend you would like to use
  --     max_width = 100,
  --     max_height = 12,
  --     max_height_window_percentage = math.huge,
  --     max_width_window_percentage = math.huge,
  --     window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
  --     window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  --     integrations = {
  --       markdown = {
  --         enabled = true,
  --         clear_in_insert_mode = false,
  --         download_remote_images = true,
  --         only_render_image_at_cursor = false,
  --         floating_windows = false, -- if true, images will be rendered in floating markdown windows
  --         filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
  --       },
  --     },
  --   },
  --   lazy = false,
  -- },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "xiyaowong/transparent.nvim",
    lazy = false
  },
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      timeout = 1,
      maxkeys = 5,
      position = "bottom-right"
    }
  },
  {
    "neovim/nvim-lspconfig",
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "custom.configs.none-ls"
    end,
  },
  {
    "gbprod/substitute.nvim",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
  },
  {
    "olimorris/codecompanion.nvim",
    version = "v17.33.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            ollama = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://192.168.1.212:11434",
                  chat_url = "/v1/chat/completions",
                },
                schema = {
                  model = { default = "qwen3" },
                },
              })
            end,
          },
        },
        strategies = {
          chat = {
            adapter = "ollama",
          },
          inline = {
            adapter = "ollama",
          },
        },
      })
    end,
    lazy = false
  },
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      local notify = require "notify"
      notify.setup {
        level = vim.log.levels.INFO,
        render = "compact",
        timeout = 3000,
        stages = "fade_in_slide_out",
        top_down = false,
      }
      vim.notify = notify
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      lsp = {
        progress = {
          enabled = true,
          view = "mini",
        },
        hover = { enabled = true },
        signature = { enabled = true },
        message = { enabled = true },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      messages = { view_search = "mini" },
      routes = {
        {
          filter = { event = "msg_show", find = "written" },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      focus = true,
      use_diagnostic_signs = true,
      modes = {
        diagnostics = {
          win = { position = "bottom", size = 12 },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "References (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false win.position=right<cr>", desc = "Symbols (Trouble)" },
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        default_prompt = "➤ ",
        win_options = {
          winblend = 10,
        },
        insert_only = false,
      },
      select = {
        backend = { "telescope", "builtin" },
        builtin = {
          winblend = 10,
          preview = false,
        },
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      jump = {
        autojump = true,
      },
      highlight = {
        backdrop = false,
      },
      modes = {
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T" },
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    dependencies = {
      "folke/twilight.nvim",
    },
    opts = {
      window = {
        backdrop = 0.9,
        width = 0.6,
        options = {
          number = false,
          relativenumber = false,
        },
      },
      plugins = {
        twilight = { enabled = true },
        gitsigns = { enabled = true },
        tmux = { enabled = false },
      },
    },
    keys = {
      { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
  },
}

return plugins
