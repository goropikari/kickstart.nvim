require('base')
require('cmds')

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
require('lazy').setup(
  {
    {
      -- colorscheme
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
    },
    {
      -- hex を色を付けて表示する
      -- :ColorizerToggle で有効になる
      'norcalli/nvim-colorizer.lua',
      cmd = { 'ColorizerToggle' },
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
            require('neo-tree.command').execute({ toggle = true })
          end,
          desc = 'Explorer NeoTree',
        },
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      init = function()
        if vim.fn.argc(-1) == 1 then
          local stat = vim.loop.fs_stat(vim.fn.argv(0))
          if stat and stat.type == 'directory' then
            require('neo-tree')
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
      -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = '0.1.x',
      dependencies = {
        'folke/which-key.nvim',
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
            return vim.fn.executable('make') == 1
          end,
        },
      },
      config = function()
        require('telescope').setup({})

        -- Enable telescope fzf native, if installed
        pcall(require('telescope').load_extension, 'fzf')
      end,
      keys = {
        {
          '<leader>?',
          function()
            require('telescope.builtin').oldfiles()
          end,
          desc = '[?] Find recently opened files',
        },
        {
          '<leader><space>',
          function()
            require('telescope.builtin').buffers()
          end,
          desc = '[ ] Find existing buffers',
        },
        {
          '<leader>/',
          function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
              winblend = 10,
              previewer = false,
            }))
          end,
          desc = '[/] Fuzzily search in current buffer',
        },
        {
          '<leader>p',
          function()
            require('telescope.builtin').find_files({ hidden = true, file_ignore_patterns = { '.git/' } })
          end,
          desc = 'search file',
        },
        {
          '<leader>sb',
          function()
            require('telescope.builtin').current_buffer_fuzzy_find()
          end,
          desc = 'Search current Buffer',
        },
        {
          '<leader>ss',
          function()
            require('telescope.builtin').builtin()
          end,
          desc = 'Search Select Telescope',
        },
        {
          '<leader>gf',
          function()
            require('telescope.builtin').git_files()
          end,
          desc = 'Search Git Files',
        },
        {
          '<leader>gs',
          function()
            require('telescope.builtin').git_status()
          end,
          desc = 'Search Git Status',
        },
        {
          '<leader>sf',
          function()
            require('telescope.builtin').find_files()
          end,
          desc = 'Search Files',
        },
        {
          '<leader>sh',
          function()
            require('telescope.builtin').help_tags()
          end,
          desc = 'Search Help',
        },
        {
          '<leader>sw',
          function()
            require('telescope.builtin').grep_string()
          end,
          desc = 'Search current Word',
        },
        {
          '<leader>sg',
          function()
            require('telescope.builtin').live_grep()
          end,
          desc = 'Search by Grep',
        },
        {
          '<leader>sd',
          function()
            require('telescope.builtin').diagnostics()
          end,
          desc = 'Search Diagnostics',
        },
      },
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
      -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
      -- command が pop up window で表示される
      'folke/noice.nvim',
      event = 'VeryLazy',
      opts = {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        'MunifTanjim/nui.nvim',
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        -- "rcarriga/nvim-notify",
      },
      keys = {
        {
          '<leader>ne',
          function()
            require('noice').cmd('error')
          end,
          desc = 'Noice Error',
        },
        {
          '<leader>nl',
          function()
            require('noice').cmd('last')
          end,
          desc = 'Noice [L]ast',
        },
      },
    },
    {
      -- vim.ui.input を cursor で選択できるようにする
      'stevearc/dressing.nvim',
      opts = {},
    },
    {
      'chentoast/marks.nvim',
      event = 'VeryLazy',
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
      keys = {
        { '<leader>bn', '<Cmd>BufferNext<CR>', desc = 'Buffer Next' },
        { '<leader>bN', '<Cmd>BufferPrevious<CR>', desc = 'Buffer Previous' },
        { '<leader>bca', '<Cmd>BufferCloseAllButCurrent<CR><C-w><C-o><CR>', desc = 'close all buffer but current' },
        { '<leader>bcc', '<Cmd>BufferClose<CR><Cmd>q<CR>', desc = 'close buffer' },
      },
    },
    {
      -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      build = ':TSUpdate',
      config = function()
        -- [[ Configure Treesitter ]]
        -- See `:help nvim-treesitter`
        -- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
        vim.defer_fn(function()
          require('nvim-treesitter.configs').setup({
            -- Add languages to be installed here that you want installed for treesitter
            ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'ruby' },

            -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
            auto_install = false,
            -- Install languages synchronously (only applied to `ensure_installed`)
            sync_install = false,
            -- List of parsers to ignore installing
            ignore_install = {},
            -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
            modules = {},
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = '<c-space>',
                node_incremental = '<c-space>',
                scope_incremental = '<c-s>',
                node_decremental = '<M-space>',
              },
            },
            textobjects = {
              select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                  -- You can use the capture groups defined in textobjects.scm
                  ['aa'] = '@parameter.outer',
                  ['ia'] = '@parameter.inner',
                  ['af'] = '@function.outer',
                  ['if'] = '@function.inner',
                  ['ac'] = '@class.outer',
                  ['ic'] = '@class.inner',
                },
              },
              move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                  [']m'] = '@function.outer',
                  [']]'] = '@class.outer',
                },
                goto_next_end = {
                  [']M'] = '@function.outer',
                  [']['] = '@class.outer',
                },
                goto_previous_start = {
                  ['[m'] = '@function.outer',
                  ['[['] = '@class.outer',
                },
                goto_previous_end = {
                  ['[M'] = '@function.outer',
                  ['[]'] = '@class.outer',
                },
              },
              swap = {
                enable = true,
                swap_next = {
                  ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                  ['<leader>A'] = '@parameter.inner',
                },
              },
            },
          })
        end, 0)
      end,
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
      -- cursor 下と同じ文字列に下線を引く'
      'xiyaowong/nvim-cursorword',
      -- event = 'VeryLazy',
    },
    {
      -- splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries, etc.
      'Wansmer/treesj',
      -- keys = { '<leader>m' },
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      keys = {
        {
          '<leader>m',
          function()
            require('treesj').toggle()
          end,
          desc = 'treesj: split/join collections',
        },
      },
      opts = {
        max_join_length = 1000,
      },
    },
    {
      'junegunn/vim-easy-align',
      keys = {
        { '<leader>A', '<Plug>(EasyAlign)*', desc = 'align', mode = 'v' },
      },
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
      keys = {
        -- terminal によって Ctrl-/ を Ctrl-_ に認識することがある。逆もしかり
        {
          '<c-_>',
          function()
            require('Comment.api').toggle.linewise.current()
          end,
          desc = 'Comment toggle linewise',
        },
        {
          '<c-/>',
          function()
            require('Comment.api').toggle.linewise.current()
          end,
          desc = 'Comment toggle linewise',
        },
        {
          '<c-_>',
          '<ESC><CMD>lua require("Comment.api").locked("toggle.linewise")(vim.fn.visualmode())<CR>',
          desc = 'Comment toggle linewise',
          mode = 'v',
        },
        {
          '<c-/>',
          '<ESC><CMD>lua require("Comment.api").locked("toggle.linewise")(vim.fn.visualmode())<CR>',
          desc = 'Comment toggle linewise',
          mode = 'v',
        },
      },
    },
    {
      -- Add/delete/change surrounding pairs
      'kylechui/nvim-surround',
      version = '*', -- Use for stability; omit to use `main` branch for the latest features
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
      keys = {
        { '<leader>sa', '<Plug>(nvim-surround-normal)iw', desc = 'surround add: [char]' },
        { '<leader>sd', '<Plug>(nvim-surround-delete)', desc = 'surround delete: [char]' },
        { '<leader>sr', '<Plug>(nvim-surround-change)', desc = 'surround replace: [from][to]' },
        { '<leader>sa', '<Plug>(nvim-surround-visual)', desc = 'surround add: [char]', mode = 'v' },
      },
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
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      },
      keys = {
        { '<leader>g', desc = 'Git' },
        {
          '<leader>ga',
          function()
            require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end,
          desc = 'stage git hunk',
          mode = 'v',
        },
      },
    },
    {
      -- github review
      'pwntester/octo.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'nvim-tree/nvim-web-devicons',
      },
      opts = {
        mappings_disable_default = false,
      },
      cmd = { 'Octo' },
    },
    {
      -- Autocompletion
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          'L3MON4D3/LuaSnip',
          build = (function()
            -- Build Step is needed for regex support in snippets
            -- This step is not supported in many windows environments
            -- Remove the below condition to re-enable on windows
            if vim.fn.has('win32') == 1 then
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

        -- neovim lua
        {
          'folke/lazydev.nvim',
          ft = 'lua', -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
          },
        },
        { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
      },
      config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        -- require('luasnip.loaders.from_vscode').lazy_load()
        -- luasnip.config.setup({})

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            completeopt = 'menu,menuone,noinsert',
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-n>'] = cmp.mapping.select_next_item(),
            -- ['<C-p>'] = cmp.mapping.select_prev_item(),
            -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
            -- ['<C-Space>'] = cmp.mapping.complete {},
            ['<CR>'] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            -- ['<S-Tab>'] = cmp.mapping(function(fallback)
            --   if cmp.visible() then
            --     cmp.select_prev_item()
            --   elseif luasnip.locally_jumpable(-1) then
            --     luasnip.jump(-1)
            --   else
            --     fallback()
            --   end
            -- end, { 'i', 's' }),
          }),
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
            {
              name = 'lazydev',
              group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            },
          },
        })
      end,
    },
    { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      keys = {
        {
          '<leader>f',
          function()
            require('conform').format({ async = true, lsp_format = 'fallback' })
          end,
          mode = '',
          desc = 'Format buffer',
        },
      },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = false, cpp = false }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'fallback'
          end
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          go = { 'goimports', 'gofumpt' },
        },
      },
    },
    {
      -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      event = 'VimEnter',
      dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        { 'j-hui/fidget.nvim', opts = {} },

        -- Allows extra capabilities provided by nvim-cmp
        'hrsh7th/cmp-nvim-lsp',
      },
      config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
          callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')

            -- Find references for the word under your cursor.
            map('gr', require('telescope.builtin').lsp_references, 'Goto References')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type Definition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('<leader>lds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map('<leader>lrn', vim.lsp.buf.rename, 'Rename')
            map('<F2>', vim.lsp.buf.rename, 'Rename')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            -- map('<leader>lca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
            map('<leader>lca', function()
              vim.lsp.buf.code_action({ context = { diagnostics = {}, only = { 'quickfix', 'refactor', 'source' } }, apply = true })
            end, 'Code Action', { 'n', 'x' })

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

            map('<leader>lK', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>ldh', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>lf', function(_)
              vim.lsp.buf.format()
            end, 'Format')
            map('<leader>lgD', vim.lsp.buf.declaration, 'Goto Declaration')
            map('<leader>lgI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
            map('<leader>lgd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
            map('<leader>lgr', require('telescope.builtin').lsp_references, 'Goto References')
            map('<leader>lk', vim.lsp.buf.signature_help, 'Signature Documentation')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
              local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event2.buf })
                end,
              })
            end

            -- The following code creates a keymap to toggle inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This may be unwanted, since they displace some of your code
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map('<leader>lth', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
              end, 'Toggle Inlay Hints')
            end
          end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local lsp_servers = {
          html = { filetypes = { 'html', 'twig', 'hbs' } },
          typos_lsp = {},
          lua_ls = {
            -- cmd = {...},
            -- filetypes = { ...},
            -- capabilities = {},
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
        }

        for executable, config in pairs({
          -- executable = {lsp = config}
          go = {
            gopls = {
              settings = {
                gopls = {
                  gofumpt = true,
                  codelenses = {
                    gc_details = false,
                    generate = true,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                  },
                  hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                  },
                  analyses = {
                    fieldalignment = true,
                    nilness = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                  },
                  usePlaceholders = true,
                  completeUnimported = true,
                  staticcheck = true,
                  directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
                  semanticTokens = true,
                },
              },
            },
          },
          ruby = {
            ruby_lsp = {},
          },
          clangd = {
            clangd = {
              -- https://www.reddit.com/r/neovim/comments/16qwp3d/comment/k261adn/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
              cmd = {
                'clangd',
                '--fallback-style=webkit',
              },
            },
          },
        }) do
          if vim.fn.executable(executable) == 1 then
            for key, val in pairs(config) do
              lsp_servers[key] = val
            end
          end
        end

        require('mason').setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(lsp_servers or {})
        vim.list_extend(ensure_installed, {
          'stylua', -- Used to format Lua code
          'goimports',
          'gofumpt',
        })
        require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

        require('mason-lspconfig').setup({
          handlers = {
            function(server_name)
              local server = lsp_servers[server_name] or {}
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for ts_ls)
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
              require('lspconfig')[server_name].setup(server)
            end,
          },
        })
        require('lspconfig').typos_lsp.setup({})
      end,
    },
    {
      'salkin-mada/openscad.nvim',
      enabled = vim.fn.executable('openscad') == 1,
      ft = { 'openscad' },
      dependencies = {
        'L3MON4D3/LuaSnip',
      },
      config = function()
        require('openscad')
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
        if vim.fn.executable('npx') then
          vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install')
        else
          vim.cmd([[Lazy load markdown-preview.nvim]])
          vim.fn['mkdp#util#install']()
        end
      end,
      init = function()
        if vim.fn.executable('npx') then
          vim.g.mkdp_filetypes = { 'markdown' }
        end
      end,
    },
    {
      'mfussenegger/nvim-dap',
      dependencies = {
        {
          -- Creates a beautiful debugger UI
          'rcarriga/nvim-dap-ui',
          dependencies = { 'nvim-neotest/nvim-nio' },
          config = function()
            local dap = require('dap')
            local dapui = require('dapui')
            dapui.setup()
            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close
          end,
        },
        {
          -- code 中に変数の値を表示する
          'theHamsta/nvim-dap-virtual-text',
          opts = {},
        },
        'nvim-telescope/telescope-dap.nvim',
      },
      keys = {
        { '<leader>d', desc = 'Debug' },
        {
          '<leader>dC',
          function()
            require('dap').clear_breakpoints()
          end,
          desc = 'Debug: Clear Breakpoint',
        },
        {
          '<leader>db',
          function()
            require('dap').toggle_breakpoint()
          end,
          desc = 'Debug: Toggle Breakpoint',
        },
        {
          '<leader>dc',
          function()
            require('dap').toggle_breakpoint(vim.fn.input('debug condition: '))
          end,
          desc = 'Debug: Toggle Conditional Breakpoint',
        },
        {
          '<leader>dt',
          function()
            require('dap-go').debug_test()
          end,
          desc = 'Debug Go Test',
        },
        {
          '<leader>duc',
          function()
            require('dapui').close()
          end,
          desc = 'Close DAP UI',
        },
        {
          '<F5>',
          function()
            require('dap').continue()
          end,
          desc = 'Debug: Continue',
        },
        {
          '<F10>',
          function()
            require('dap').step_over()
          end,
          desc = 'Debug: Step over',
        },
      },
    },
    {
      'leoluz/nvim-dap-go',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'go' },
      enabled = vim.fn.executable('go') == 1,
      config = function()
        local dap = require('dap')
        require('dap-go').setup()

        dap.adapters.delve = function(callback, config)
          ---@diagnostic disable-next-line
          callback({ type = 'server', host = config.host, port = config.port })
        end
        -- dap.adapters.delve = { -- ベタ書きする方法もある
        --   type = 'server',
        --   host = '127.0.0.1',
        --   port = 8081,
        -- }
      end,
      build = function()
        vim.system({
          'go',
          'install',
          'github.com/go-delve/delve/cmd/dlv@latest',
        })
      end,
    },
    {
      'mfussenegger/nvim-dap-python',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'python' },
      enabled = vim.fn.executable('python') == 1,
      config = function()
        require('dap-python').setup('python')
      end,
    },
    {
      'goropikari/nvim-dap-rdbg',
      -- dir = '/home/arch/workspace/github/nvim-dap-rdbg',
      dependencies = {
        'mfussenegger/nvim-dap',
      },
      lazy = true,
      ft = { 'ruby' },
      enabled = vim.fn.executable('ruby') == 1,
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
        'nvim-lua/plenary.nvim',
      },
      lazy = true,
      ft = { 'c', 'cpp' },
      enabled = vim.fn.executable('g++') == 1 or vim.fn.executable('gcc') == 1,
      opts = {
        configurations = {
          {
            name = 'Build and debug active file with test.txt',
            type = 'cppdbg',
            request = 'launch',
            program = '${fileDirname}/${fileBasenameNoExtension}',
            cwd = '${fileDirname}',
            args = { '<', 'test.txt' },
          },
        },
      },
      -- build = function()
      --   require('dap-cpp').install_cpptools()
      -- end,
    },
    {
      'nvim-neotest/neotest',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'antoinemadec/FixCursorHold.nvim',
        'nvim-treesitter/nvim-treesitter',
        {
          'nvim-neotest/neotest-go',
          enabled = vim.fn.executable('go') == 1,
        },
      },
      -- keys = { '<leader>t' },
      keys = {
        { '<leader>t', desc = 'Test' },
        {
          '<leader>ta',
          function()
            require('neotest').run.run(vim.fn.expand('%'))
            require('neotest').summary.open()
          end,
          desc = 'Test All',
        },
        {
          '<leader>td',
          function()
            ---@diagnostic disable-next-line
            require('neotest').run.run({ strategy = 'dap' })
          end,
          desc = 'Test Debug',
        },
        {
          '<leader>to',
          function()
            require('neotest').output.open()
          end,
          desc = 'Test Output',
        },
        {
          '<leader>ts',
          function()
            local exrc = vim.g.exrc
            local env = (exrc and exrc.neotest and exrc.neotest.env) or {}
            ---@diagnostic disable-next-line
            require('neotest').run.run({ env = env })
            require('neotest').summary.open()
          end,
          desc = 'Test Single',
        },
      },
      config = function()
        local neotest_ns = vim.api.nvim_create_namespace('neotest')
        vim.diagnostic.config({
          virtual_text = {
            format = function(diagnostic)
              local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
              return message
            end,
          },
        }, neotest_ns)

        local langs = {
          {
            executable = 'go',
            plugin_name = 'neotest-go',
            opts = {
              args = { '--shuffle=on' },
              experimental = {
                test_table = true,
              },
            },
          },
        }
        local adapters = {}
        for _, v in pairs(langs) do
          if vim.fn.executable(v.executable) == 1 then
            table.insert(adapters, require(v.plugin_name)(v.opts))
          end
        end

        ---@diagnostic disable-next-line
        require('neotest').setup({
          diagnostic = {
            enabled = true,
            severity = 4,
          },
          status = {
            enabled = true,
            signs = true,
            virtual_text = true,
          },
          output = {
            enabled = true,
            open_on_run = true,
          },
          -- your neotest config here
          adapters = adapters,
          log_level = 3,
        })
      end,
    },
    {
      -- 開いている window を番号で選択する
      'goropikari/chowcho.nvim',
      -- dir = '~/workspace/github/chowcho.nvim',
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
      keys = {
        {
          '<leader>CC',
          function()
            require('chowcho').run()
          end,
          desc = 'choose window',
        },
      },
    },
    {
      -- Ctrl-t でターミナルを出す
      'akinsho/toggleterm.nvim',
      dependencies = {
        'nvim-telescope/telescope.nvim',
        -- toggleterm で開いた terminal を telescope で検索する
        'tknightz/telescope-termfinder.nvim',
      },
      version = '*',
      cmd = { 'ToggleTerm' },
      -- opts = {
      --   open_mapping = [[<c-\>]],
      --   direction = 'float',
      --   winbar = {
      --     enabled = true,
      --     name_formatter = function(term) --  term: Terminal
      --       return term.name
      --     end,
      --   },
      -- },
      keys = {
        {
          '<c-t>',
          function()
            vim.cmd('ToggleTerm')
          end,
          mode = { 'n', 't' },
        },
        {
          '<leader>st',
          function()
            vim.cmd([[Telescope termfinder find]])
          end,
          desc = 'Search ToggleTerm',
        },
      },
      config = function()
        require('toggleterm').setup({
          open_mapping = [[<c-\>]],
          direction = 'float',
          -- direction = 'horizontal',
          -- winbar = {
          --   enabled = true,
          --   name_formatter = function(term) --  term: Terminal
          --     return term.name
          --   end,
          -- },
        })
        require('telescope').load_extension('termfinder')
      end,
    },
    {
      -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      opts = {
        expand = 1,
        spec = {
          {
            '<leader>cd',
            function()
              vim.cmd(':tcd ' .. vim.fn.expand('%:p:h'))
            end,
            desc = 'change directory of current file',
          },
          {
            '<leader>ce',
            function()
              vim.cmd(':tabnew ~/.config/nvim/init.lua')
              vim.cmd(':tcd ~/.config/nvim')
              -- vim.cmd('Neotree show')
            end,
            desc = 'edit neovim config',
          },

          -- document existing key chains
          { '<leader>s', group = 'Search or surround' },
          { '<leader>s_', hidden = true },

          -- Diagnostic keymaps
          { '<leader>e', vim.diagnostic.open_float, desc = 'Open floating diagnostic message' },
          { '<leader>q', vim.diagnostic.setloclist, desc = 'Open diagnostics list' },

          -- [[ osc52 ]]
          -- ssh, docker 内で copy したものをホストの clipboard に入れる
          {
            '<leader>y',
            expr = true,
            group = 'Yank',
            replace_keycodes = false,
          },

          -- [[ Noice ]]
          { '<leader>n', desc = 'Noice' },

          -- [[ barbar.nvim ]]
          { '<leader>b', group = 'Buffer' },
          { '<leader>bc', group = 'Buffer Clear' },

          { '<leader>d', group = 'Debug' },
          { '<leader>g', group = 'Git' },
          { '<leader>l', group = 'LSP' },
        },
      },
    },
    {
      -- ssh, docker 内で copy したものをホストの clipboard に入れる
      'ojroques/nvim-osc52',
      event = 'VeryLazy',
      keys = {
        {
          '<leader>y',
          desc = 'Yank',
        },
        {
          '<leader>y',
          function()
            require('osc52').copy_visual()
          end,
          desc = 'osc52: copy clipboard',
          mode = 'v',
        },
        {
          '<leader>ya',
          function()
            require('osc52').copy(vim.fn.expand('%:p'))
          end,
          desc = 'osc52: copy file absolute path',
        },
        {
          '<leader>yf',
          function()
            require('osc52').copy(vim.fn.expand('%:t'))
          end,
          desc = 'osc52: copy current file name',
        },
        {
          '<leader>yr',
          function()
            require('osc52').copy(vim.fn.expand('%'))
          end,
          desc = 'osc52: copy file relative path',
        },
        {
          '<leader>yy',
          '<leader>y_',
          desc = 'osc52: copy line',
          -- remap = true,
        },
      },
    },
    {
      -- Highlight todo, notes, etc in comments
      'folke/todo-comments.nvim',
      event = 'VimEnter',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { signs = false },
    },
    {
      -- avoid nested neovim session
      'willothy/flatten.nvim',
      opts = {},
    },
    {
      -- google 検索
      'voldikss/vim-browser-search',
      keys = {
        { '<leader>w', '<Plug>SearchVisual', 'google select word', mode = 'v' },
      },
    },
    {
      'goropikari/local-devcontainer.nvim',
      -- dir = '~/workspace/github/local-devcontainer.nvim',
      enabled = vim.fn.executable('devcontainer') == 1,
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

require('custom.plugins')
vim.cmd('colorscheme gruvbox')
