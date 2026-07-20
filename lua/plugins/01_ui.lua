local tab_buffers = {}

return {
  {
    'neanias/everforest-nvim',
    event = 'VeryLazy',
    config = function()
      require('everforest').setup({
        italic = false,
        disable_italic_comments = true,
        on_highlights = function(hl, palette)
          hl.LineNr = { fg = '#C0D4C0' }
          hl.Comment = { fg = '#50B010' }
        end,
      })
      vim.cmd('colorscheme everforest')
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
  },
  {
    'cocopon/iceberg.vim',
  },
  {
    'EdenEast/nightfox.nvim',
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      input = {
        enabled = true,
      },
      picker = {
        enabled = true,
        ui_select = true,
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      local group = vim.api.nvim_create_augroup('tab_buffers', { clear = true })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        callback = function(args)
          if vim.bo[args.buf].buflisted then
            local tab = vim.api.nvim_get_current_tabpage()
            tab_buffers[tab] = tab_buffers[tab] or {}
            tab_buffers[tab][args.buf] = true
          end
        end,
      })
    end,
    keys = {
      {
        '<leader>:',
        function()
          require('snacks').picker.commands()
        end,
        desc = 'Command picker',
      },
      {
        '<leader><space>',
        function()
          local tab = vim.api.nvim_get_current_tabpage()
          local current_tab_buffers = tab_buffers[tab] or {}

          -- The current buffer may have been entered before the autocmd was set.
          local current_buf = vim.api.nvim_get_current_buf()
          if vim.bo[current_buf].buflisted then
            current_tab_buffers[current_buf] = true
            tab_buffers[tab] = current_tab_buffers
          end

          require('snacks').picker.buffers({
            filter = {
              filter = function(item)
                return current_tab_buffers[item.buf] == true
              end,
            },
          })
        end,
        desc = 'Find existing buffers',
      },
      {
        '<leader>p',
        function()
          require('snacks').picker.files({
            hidden = true,
            ignored = true,
            exclude = { '.git', 'node_modules' },
          })
        end,
        desc = 'search file',
      },
      {
        '<leader>sg',
        function()
          require('snacks').picker.grep()
        end,
        desc = 'Search by Grep',
      },
      {
        '<leader>P',
        function()
          require('snacks').picker.pickers()
        end,
        desc = 'Search by Grep',
      },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function() ---@diagnostic disable-line
      local highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      }

      local hooks = require('ibl.hooks')
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#C06C75' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#C5C07B' })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AAEF' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#C19A66' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#68C379' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#A678D0' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#16B6C0' })
      end)

      require('ibl').setup({
        indent = {
          highlight = highlight,
          char = '▏',
        },
      })
    end,
  },
  {
    'yamatsum/nvim-cursorline',
    opts = {
      cursorline = {
        enable = false,
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
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
          end,
          desc = 'edit neovim config',
        },
        { '<leader>s', group = 'Search or surround' },
        { '<leader>s_', hidden = true },
        {
          '<leader>e',
          function()
            vim.diagnostic.open_float({
              suffix = function(diagnostic)
                local utils = require('utils')
                local href = utils.dig(diagnostic, { 'user_data', 'lsp', 'codeDescription', 'href' })
                if href == '' then
                  return string.format(' (%s: %s)', diagnostic.source, diagnostic.code), ''
                else
                  return string.format(' (%s: %s, %s)', diagnostic.source, diagnostic.code, href), ''
                end
              end,
            })
          end,
          desc = 'Open floating diagnostic message',
        },
        {
          '<leader>q',
          function()
            require('snacks').picker.diagnostics_buffer()
          end,
          desc = 'Open diagnostics list',
        },
        {
          '<leader>y',
          expr = true,
          group = 'Yank',
          replace_keycodes = false,
        },
        {
          '<leader>y',
          function()
            local path = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")

            if start_line > end_line then
              start_line, end_line = end_line, start_line
            end

            local value
            if start_line == end_line then
              value = string.format('%s:L%s', path, start_line)
            else
              value = string.format('%s:L%s-L%s', path, start_line, end_line)
            end

            vim.fn.setreg('+', value)
          end,
          mode = 'v',
          desc = 'clipboard: copy relative path with selected line range',
        },
        {
          '<leader>ya',
          function()
            vim.fn.setreg('+', vim.fn.expand('%:p'))
          end,
          desc = 'clipboard: copy file absolute path',
        },
        {
          '<leader>yf',
          function()
            vim.fn.setreg('+', vim.fn.expand('%:t'))
          end,
          desc = 'clipboard: copy current file name',
        },
        {
          '<leader>yr',
          function()
            vim.fn.setreg('+', vim.fn.expand('%'))
          end,
          desc = 'clipboard: copy file relative path',
        },
        {
          '<leader>yy',
          function()
            vim.cmd('%y+')
          end,
          desc = 'copy entire file to clipboard',
        },
        { '<leader>b', group = 'Buffer' },
        { '<leader>bc', group = 'Buffer Clear' },
        { '<leader>d', group = 'Debug' },
        { '<leader>g', group = 'Git' },
        { '<leader>l', group = 'LSP' },
        { '<leader>r', group = 'Bookmark' },
        {
          '<leader>u',
          function()
            local uri = vim.fn.expand('<cWORD>')
            local pattern = '[%w-]+:.*'
            if string.match(uri, pattern) then
              vim.ui.open(uri)
            else
              vim.notify('not uri')
            end
          end,
          desc = 'open uri',
        },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'BufEnter',
    version = '*',
    config = function()
      require('todo-comments').setup({
        signs = false,
      })
      for name, _ in pairs(vim.api.nvim_get_commands({ builtin = false })) do
        if name:find('Todo') then
          vim.api.nvim_del_user_command(name)
        end
      end
    end,
  },
}
