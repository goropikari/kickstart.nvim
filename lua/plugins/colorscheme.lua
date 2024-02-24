return {
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
  }

  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   lazy = false,
  --   -- config = function()
  --   --   require('onedark').setup {
  --   --     -- Set a style preset. 'dark' is default.
  --   --     style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
  --   --   }
  --   --   require('onedark').load()
  --   -- end,
  -- },
  -- {
  --   "ntk148v/habamax.nvim",
  --   dependencies = { "rktjmp/lush.nvim" },
  --   priority = 1000,
  --   lazy = false,
  --   -- config = function()
  --   --   vim.cmd('colorscheme habamax.nvim')
  --   -- end
  -- },
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd('colorscheme gruvbox')
  --   end
  -- },

  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   lazy = false,
  --   -- config = function()
  --   --   require('onedark').setup {
  --   --     -- Set a style preset. 'dark' is default.
  --   --     style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
  --   --   }
  --   --   require('onedark').load()
  --   -- end,
  -- },
  -- {
  --   "ntk148v/habamax.nvim",
  --   dependencies = { "rktjmp/lush.nvim" },
  --   priority = 1000,
  --   lazy = false,
  --   -- config = function()
  --   --   vim.cmd('colorscheme habamax.nvim')
  --   -- end
  -- },
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd('colorscheme gruvbox')
  --   end
  -- },
}
