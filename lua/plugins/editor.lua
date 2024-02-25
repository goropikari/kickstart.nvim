-- [[UI]]
return {
  -- colorscheme
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    lazy = true,
    -- config = function()
    --   require('onedark').setup {
    --     -- Set a style preset. 'dark' is default.
    --     style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
    --   }
    --   require('onedark').load()
    -- end,
  },
  {
    "ntk148v/habamax.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    priority = 1000,
    lazy = true,
    -- config = function()
    --   vim.cmd('colorscheme habamax.nvim')
    -- end
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd('colorscheme gruvbox')
    end
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = true,
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
      "rcarriga/nvim-notify",
    },
  },
  {
    -- vim.ui.input を cursor で選択できるようにする
    'stevearc/dressing.nvim',
    opts = {},
  },
  {
    "goropikari/chowcho.nvim",
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
  }
}
