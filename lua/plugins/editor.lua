-- [[UI]]
return {
  -- colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
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
}
