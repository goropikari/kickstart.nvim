-- [[UI]]
return {
  -- colorscheme
  {
    "ellisonleao/gruvbox.nvim",
  },
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
    -- command が pop up window で表示される
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- "rcarriga/nvim-notify",
    },
  },
  {
    -- vim.ui.input を cursor で選択できるようにする
    'stevearc/dressing.nvim',
    opts = {},
  },
  {
    "goropikari/chowcho.nvim",
    -- dir = '~/workspace/github/chowcho.nvim',
    branch = 'fix',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    -- splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries, etc.
    'Wansmer/treesj',
    -- keys = { '<leader>m' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = { { '<leader>m', function() require('treesj').toggle() end, desc = "split/join collections" } },
    opts = {
      max_join_length = 1000,
    },
  },
  {
    -- cursor 下と同じ文字のものをハイライトする
    "RRethy/vim-illuminate",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp', 'treesitter', 'regex' },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },
  -- cursor 下と同じ文字列に下線を引く'
  {
    'xiyaowong/nvim-cursorword',
  },

  -- Ctrl-t でターミナルを出す
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = true,
  },
  {
    -- :FixWhitespace で末端空白を消す
    'bronson/vim-trailing-whitespace'
  },

  -- github review
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require "octo".setup({
        mappings_disable_default = false,
        -- mappings = {
        --   review_thread = {
        --     toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
        --     goto_file = { lhs = "gf", desc = "go to file" },
        --   },
        -- },
      })
    end,
  },

  -- hex を色を付けて表示する
  -- :ColorizerToggle で有効になる
  {
    'norcalli/nvim-colorizer.lua'
  },

  -- scrollbar
  {
    'petertriho/nvim-scrollbar',
    config = function()
      require("scrollbar").setup()
    end
  },

  -- buffer を tab で表示する
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },


  -- {
  --   'echasnovski/mini.surround',
  --   version = '*',
  --   config = function()
  --     require('mini.surround').setup({
  --       mappings = {
  --         add = 'sa',            -- Add surrounding in Normal and Visual modes
  --         delete = 'sd',         -- Delete surrounding
  --         find = 'sf',           -- Find surrounding (to the right)
  --         find_left = 'sF',      -- Find surrounding (to the left)
  --         highlight = 'sh',      -- Highlight surrounding
  --         replace = 'sr',        -- Replace surrounding
  --         update_n_lines = 'sn', -- Update `n_lines`
  --
  --         suffix_last = 'l',     -- Suffix to search with "prev" method
  --         suffix_next = 'n',     -- Suffix to search with "next" method
  --       },
  --     })
  --   end
  -- },

  -- Add/delete/change surrounding pairs
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          -- default keymap を無効化
          insert          = false,
          insert_line     = false,
          normal          = false,
          normal_cur      = false,
          normal_line     = false,
          normal_cur_line = false,
          visual          = false,
          visual_line     = false,
          delete          = false,
          change          = false,
          change_line     = false,
        },
      })
    end
  },

  {
    'junegunn/vim-easy-align'
  },
}
