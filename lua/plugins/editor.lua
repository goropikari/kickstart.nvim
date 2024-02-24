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
    config = function()
      require('chowcho').setup {
        -- Must be a single character. The length of the array is the maximum number of windows that can be moved.
        labels = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" },
        use_exclude_default = true,
        ignore_case = true,
        exclude = function(buf, win)
          -- exclude noice.nvim's cmdline_popup
          local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if bt == "nofile" and (ft == "noice" or ft == "vim") then
            return true
          end
          return false
        end,
        selector = {
          float = {
            border_style = "rounded",
            icon_enabled = true,
            color = {
              label = {
                active = "#c8cfff",
                inactive = "#ababab",
              },
              text = {
                active = "#fefefe",
                inactive = "#d0d0d0",
              },
              border = {
                active = "#b400c8",
                inactive = "#fefefe",
              },
            },
            zindex = 1,
          },
          statusline = {
            color = {
              label = {
                active = "#fefefe",
                inactive = "#d0d0d0",
              },
              background = {
                active = "#3d7172",
                inactive = "#203a3a",
              },
            },
          },
        },
      }
    end
  },
}
