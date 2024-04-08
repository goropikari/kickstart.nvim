--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.o.shell = 'bash'

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup(
  {
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    'tpope/vim-fugitive',
    -- 'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    {
      -- Autocompletion
      'hrsh7th/nvim-cmp',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          'L3MON4D3/LuaSnip',
          build = (function()
            -- Build Step is needed for regex support in snippets
            -- This step is not supported in many windows environments
            -- Remove the below condition to re-enable on windows
            if vim.fn.has 'win32' == 1 then
              return
            end
            return 'make install_jsregexp'
          end)(),
        },
        'saadparwaiz1/cmp_luasnip',

        -- Adds LSP completion capabilities
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',

        -- Adds a number of user-friendly snippets
        'rafamadriz/friendly-snippets',
      },
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim', opts = {} },
    {
      -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
    },

    {
      -- Set lualine as statusline
      'nvim-lualine/lualine.nvim',
      -- See `:help lualine.txt`
    },

    {
      -- Add indentation guides even on blank lines
      'lukas-reineke/indent-blankline.nvim',
      -- Enable `lukas-reineke/indent-blankline.nvim`
      -- See `:help ibl`
      main = 'ibl',
      opts = {},
    },

    -- Ctrl-/ でコメント
    {
      'numToStr/Comment.nvim',
      opts = {
        mappings = false,
      },
    },

    -- Fuzzy Finder (files, lsp, etc)
    {
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      dependencies = {
        'nvim-lua/plenary.nvim',
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          -- NOTE: If you are having trouble with this installation,
          --       refer to the README for telescope-fzf-native for more instructions.
          build = 'make',
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
      },
    },

    -- sidebar file explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = 'Neotree',
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      },
      keys = {
        {
          "<c-e>", -- Ctrl-e で neo-tree の表示切り替え
          function()
            require("neo-tree.command").execute({ toggle = true })
          end,
          desc = "Explorer NeoTree",
        },
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      init = function()
        if vim.fn.argc(-1) == 1 then
          local stat = vim.loop.fs_stat(vim.fn.argv(0))
          if stat and stat.type == "directory" then
            require("neo-tree")
          end
        end
      end,
    },

    -- {
    --   -- vimium のような感じでコードジャンプできる
    --   "folke/flash.nvim",
    --   event = "VeryLazy",
    -- },

    {
      -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      build = ':TSUpdate',
    },

    {
      -- ssh, docker 内で copy したものをホストの clipboard に入れる
      'ojroques/nvim-osc52',
    },


    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    -- require 'kickstart.plugins.autoformat',
    require 'plugins.editor',
    require 'plugins.language',
    require 'plugins.test',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },
  },

  -- options
  {
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      concurrency = nil, ---@type number? set to 1 to check for updates very slowly
      notify = false,       -- get a notification when new updates are found
      frequency = 3600,     -- check for updates every hour
      check_pinned = false, -- check for pinned packages that can't be updated
    },
    change_detection = {
      -- automatically check for config file changes and reload the ui
      enabled = true,
      notify = true, -- get a notification when changes are found
    },
    performance = {
      rtp = {
        disabled_plugins = {
          -- "netrw",
          -- "netrwPlugin",
          -- "netrwSettings",
          "gzip",
          -- "matchit",
          -- "matchparen",
          -- "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin", -- "netrwFileHandlers",
        },
      },
    },
  }
)

-- [[ Setting options ]]
require 'custom.plugins.base'
require 'custom.plugins.editor'

-- [[ Basic Keymaps ]]
require 'custom.plugins.keymaps'

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
require 'custom.plugins.telescope'

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
require 'custom.plugins.treesitter'

-- [[ Configure LSP ]]
require 'custom.plugins.lsp'

-- [[ Configure Test ]]
require 'custom.plugins.test'

-- [[ Configure nvim-cmp ]]
require 'custom.plugins.nvim_cmp'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- [[ 競技プログラミング用 ]]
vim.api.nvim_create_user_command('Make', function()
  vim.cmd('messages clear')
  print(vim.fn.system({ 'make', 'test', 'ARGS=' .. vim.fn.expand('%:r') }))
  vim.cmd('messages')
end, {})
