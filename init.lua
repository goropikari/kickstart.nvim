vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.o.shell = 'bash'
vim.o.exrc = true -- current directory の .nvim.lua を読み込む

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
require('lazy').setup(
  {
    -- colorscheme
    {
      'ellisonleao/gruvbox.nvim',
      opts = {
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = true,
        },
        undercurl = true,
        underline = true,
        bold = false,
        overrides = {
          LineNr = { fg = '#C0D4C0' }, -- line number の色を変える
          Comment = { fg = '#50B010' }, -- comment の色を変える
        },
      },
      init = function()
        vim.cmd 'colorscheme gruvbox'
      end,
    },
    {
      -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      build = ':TSUpdate',
    },
    {
      -- Set lualine as statusline
      'nvim-lualine/lualine.nvim',
      opts = {
        options = {
          icons_enabled = false,
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 3,
            },
          },
        },
      },
    },
    {
      -- indent を見やすくする
      'shellRaining/hlchunk.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        chunk = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      },
    },
    {
      -- sidebar file explorer
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v3.x',
      -- cmd = 'Neotree',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      },
      keys = {
        {
          '<c-e>', -- Ctrl-e で neo-tree の表示切り替え
          function()
            require('neo-tree.command').execute { toggle = true }
          end,
          desc = 'Explorer NeoTree',
        },
      },
      deactivate = function()
        vim.cmd [[Neotree close]]
      end,
      init = function()
        if vim.fn.argc(-1) == 1 then
          local stat = vim.loop.fs_stat(vim.fn.argv(0))
          if stat and stat.type == 'directory' then
            require 'neo-tree'
          end
        end
      end,
      opts = {
        sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
        open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
        hijack_netrw_behavior = 'disabled',
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_dotfiles = false,
          },
        },
        window = {
          position = 'float',
          mappings = {
            ['<space>'] = 'none',
            ['Y'] = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg('+', path, 'c')
            end,
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
        },
      },
    },
    {
      -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
      -- command が pop up window で表示される
      'folke/noice.nvim',
      event = 'VeryLazy',
      opts = {
        -- add any options here
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        'MunifTanjim/nui.nvim',
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
      -- buffer を tab で表示する
      'romgrk/barbar.nvim',
      event = 'VeryLazy',
      dependencies = {
        'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
        'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
      },
      init = function()
        vim.g.barbar_auto_setup = false
      end,
      opts = {
        animation = false,
      },
      version = '^1.0.0', -- optional: only update when a new 1.x version is released
    },
    {
      -- Ctrl-t でターミナルを出す
      'akinsho/toggleterm.nvim',
      version = '*',
      opts = {
        open_mapping = [[<c-\>]],
      },
      cmd = { 'ToggleTerm' },
    },
    {
      -- cursor 下と同じ文字列に下線を引く'
      'xiyaowong/nvim-cursorword',
      event = 'VeryLazy',
    },
    {
      -- cursor 下と同じ文字のものをハイライトする
      'RRethy/vim-illuminate',
      event = 'VeryLazy',
      opts = {
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = { 'lsp', 'treesitter', 'regex' },
        },
      },
      config = function(_, opts)
        require('illuminate').configure(opts)
      end,
    },
    {
      -- Fuzzy Finder (files, lsp, etc)
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
    {
      'goropikari/chowcho.nvim',
      -- dir = '~/workspace/github/chowcho.nvim',
      lazy = true,
      keys = { '<leader>CC' },
      branch = 'fix',
      dependencies = {
        'nvim-tree/nvim-web-devicons',
      },
      opts = {
        -- Must be a single character. The length of the array is the maximum number of windows that can be moved.
        labels = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
        use_exclude_default = true,
        ignore_case = true,
        exclude = function(buf, win)
          -- exclude noice.nvim's cmdline_popup
          local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
          local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
          if bt == 'nofile' and (ft == 'noice' or ft == 'vim') then
            return true
          end
          return false
        end,
        selector_style = 'float',
        selector = {
          float = {
            border_style = 'rounded',
            icon_enabled = true,
            color = {
              label = { active = '#c8cfff', inactive = '#ababab' },
              text = { active = '#fefefe', inactive = '#d0d0d0' },
              border = { active = '#b400c8', inactive = '#fefefe' },
            },
            zindex = 1,
          },
          statusline = {
            color = {
              label = { active = '#fefefe', inactive = '#d0d0d0' },
              background = { active = '#3d7172', inactive = '#203a3a' },
            },
          },
        },
      },
    },
    {
      -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      opts = {},
    },
    {
      -- ssh, docker 内で copy したものをホストの clipboard に入れる
      'ojroques/nvim-osc52',
      event = 'VeryLazy',
    },
    {
      -- splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries, etc.
      'Wansmer/treesj',
      -- keys = { '<leader>m' },
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      keys = { {
        '<leader>m',
        function()
          require('treesj').toggle()
        end,
        desc = 'split/join collections',
      } },
      opts = {
        max_join_length = 1000,
      },
    },
    {
      -- Add/delete/change surrounding pairs
      'kylechui/nvim-surround',
      version = '*', -- Use for stability; omit to use `main` branch for the latest features
      event = 'VeryLazy',
      opts = {
        keymaps = {
          -- default keymap を無効化
          insert = false,
          insert_line = false,
          normal = false,
          normal_cur = false,
          normal_line = false,
          normal_cur_line = false,
          visual = false,
          visual_line = false,
          delete = false,
          change = false,
          change_line = false,
        },
      },
    },
    {
      'junegunn/vim-easy-align',
      event = 'VeryLazy',
    },
    {
      -- :FixWhitespace で末端空白を消す
      'bronson/vim-trailing-whitespace',
      cmd = { 'FixWhitespace' },
    },
    {
      -- Ctrl-/ でコメント
      'numToStr/Comment.nvim',
      opts = {
        mappings = false,
      },
      keys = { '<c-/>', '<c-_>' },
    },
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
    {
      -- avoid nested neovim session
      'willothy/flatten.nvim',
      config = true,
      lazy = false,
      priority = 1001,
    },
    {
      -- Git related plugins
      'tpope/vim-fugitive',
      event = 'VeryLazy',
    },
    {
      -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      event = 'VeryLazy',
      dependencies = {
        'petertriho/nvim-scrollbar',
      },
      opts = {},
    },
    {
      -- github review
      'pwntester/octo.nvim',
      event = 'VeryLazy',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'nvim-tree/nvim-web-devicons',
      },
      opts = {
        mappings_disable_default = false,
      },
    },
    {
      -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { 'j-hui/fidget.nvim', opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        'folke/neodev.nvim',
      },
    },
    {
      -- hex を色を付けて表示する
      -- :ColorizerToggle で有効になる
      'norcalli/nvim-colorizer.lua',
      event = 'VeryLazy',
      cmd = { 'ColorizerToggle' },
    },
    {
      'salkin-mada/openscad.nvim',
      ft = { 'openscad' },
      dependencies = {
        'L3MON4D3/LuaSnip',
      },
      config = function()
        require 'openscad'
        -- load snippets, note requires
        vim.g.openscad_load_snippets = true
      end,
    },
    {
      'neoclide/jsonc.vim',
      ft = { 'json', 'jsonc' },
    },
    {
      -- markdown
      -- :MarkdownPreview で browser で markdown が表示される
      'iamcco/markdown-preview.nvim',
      cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
      ft = { 'markdown' },
      build = function(plugin)
        if vim.fn.executable 'npx' then
          vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install')
        else
          vim.cmd [[Lazy load markdown-preview.nvim]]
          vim.fn['mkdp#util#install']()
        end
      end,
      init = function()
        if vim.fn.executable 'npx' then
          vim.g.mkdp_filetypes = { 'markdown' }
        end
      end,
    },
    {
      -- Mason dap
      'jay-babu/mason-nvim-dap.nvim',
      event = 'VeryLazy',
      dependencies = {
        'williamboman/mason.nvim',
      },
      config = function()
        local dap_adapters = {}
        local langs = {
          -- { executable, dap-adapter }
          { lang = 'go', adapter = 'delve' },
          { lang = 'python', adapter = 'debugpy' },
        }
        for _, config in ipairs(langs) do
          if vim.fn.executable(config.lang) == 1 and config.adapter then
            table.insert(dap_adapters, config.adapter)
          end
        end

        -- install dap adapter
        require('mason-nvim-dap').setup {
          automatic_installation = true,
          ensure_installed = dap_adapters,
        }
      end,
    },
    {
      'mfussenegger/nvim-dap',
      lazy = true,
      dependencies = {
        {
          -- Creates a beautiful debugger UI
          'rcarriga/nvim-dap-ui',
          dependencies = { 'nvim-neotest/nvim-nio' },
          config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'
            dapui.setup()
            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close
          end,
        },
        'theHamsta/nvim-dap-virtual-text', -- code 中に変数の値を表示する
        'nvim-telescope/telescope-dap.nvim',
      },
    },
    {
      'leoluz/nvim-dap-go',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'go' },
      config = function()
        local dap = require 'dap'
        require('dap-go').setup()

        dap.adapters.delve = function(callback, config)
          callback { type = 'server', host = config.host, port = config.port }
        end
        -- dap.adapters.delve = { -- ベタ書きする方法もある
        --   type = 'server',
        --   host = '127.0.0.1',
        --   port = 8081,
        -- }
      end,
    },
    {
      'mfussenegger/nvim-dap-python',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'python' },
      opts = {},
    },
    {
      'goropikari/nvim-dap-rdbg',
      -- dir = '/home/arch/workspace/github/nvim-dap-rdbg',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'ruby' },
      opts = {
        configurations = {
          {
            type = 'rdbg',
            name = 'Ruby Debugger: Current File (bundler)',
            request = 'launch',
            command = 'ruby',
            script = '${file}',
            use_bundler = true,
          },
        },
      },
    },
    {
      'goropikari/nvim-dap-cpp',
      -- dir = '/home/arch/workspace/github/nvim-dap-cpp',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'cpp' },
      opts = {
        configurations = {
          {
            name = 'g++ - Build and debug active file with test.txt',
            type = 'cppdbg',
            request = 'launch',
            program = '${fileDirname}/${fileBasenameNoExtension}',
            cwd = '${fileDirname}',
            args = { '<', 'test.txt' },
          },
        },
      },
    },
    {
      'nvim-neotest/neotest',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'antoinemadec/FixCursorHold.nvim',
        'nvim-treesitter/nvim-treesitter',

        -- language adapter
        {
          url = 'https://github.com/wwnbb/neotest-go',
          branch = 'feat/dap-support',
        },
      },
      lazy = true,
    },
    {
      'ckipp01/stylua-nvim',
      opts = {},
      ft = { 'lua' },
    },
    {
      'goropikari/local-devcontainer.nvim',
      -- dir = '~/workspace/github/local-devcontainer.nvim',
      cmd = { 'DevContainerUp' },
      dependencies = {
        'ojroques/nvim-osc52',
        -- dir = '~/workspace/github/termitary-mod.nvim',
        'goropikari/termitary-mod.nvim',
      },
      opts = {
        -- cmd = 'alacritty -e',
        -- cmd = 'zellij run -- ',
        devcontainer = {
          path = 'devcontainer',
          args = {
            '--workspace-folder=.',
            -- '--skip-non-blocking-commands',
            '--skip-post-attach=true',
            '--skip-post-create=true',
            '--mount "type=bind,source=$(pwd),target=/workspaces/$(basename $(pwd))"',
            '--mount "type=bind,source=$HOME/.config/nvim,target=/home/vscode/.config/nvim"',
            '--mount "type=bind,source=$HOME/.aws,target=/home/vscode/.aws"',
            [[--additional-features='{"ghcr.io/goropikari/devcontainer-feature/neovim:1": {}, "ghcr.io/devcontainers/features/sshd:1": {}}']],
          },
        },
      },
    },
  },

  -- options
  {
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      concurrency = nil, ---@type number? set to 1 to check for updates very slowly
      notify = false, -- get a notification when new updates are found
      frequency = 3600, -- check for updates every hour
      check_pinned = false, -- check for pinned packages that can't be updated
    },
    change_detection = {
      -- automatically check for config file changes and reload the ui
      enabled = true,
      notify = false, -- get a notification when changes are found
    },
    performance = {
      rtp = {
        disabled_plugins = {
          'netrw',
          'netrwPlugin',
          'netrwSettings',
          'gzip',
          -- "matchit",
          -- "matchparen",
          'netrwPlugin',
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin', -- "netrwFileHandlers",
        },
      },
    },
  }
)

require 'custom.plugins'

-- [[ 競技プログラミング用 ]]
vim.api.nvim_create_user_command('Make', function()
  vim.cmd 'messages clear'
  print(vim.fn.system { 'make', 'test', 'ARGS=' .. vim.fn.expand '%:r' })
  vim.cmd 'messages'
end, {})

vim.api.nvim_create_user_command('DevContainerUp', function()
  require('local-devcontainer').up()
end, {})
