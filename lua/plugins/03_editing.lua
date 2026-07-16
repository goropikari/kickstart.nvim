return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'go',
        'json',
        'lua',
        'python',
        'ruby',
        'vim',
        'vimdoc',
      },
    },
    config = function(_, opts)
      require('nvim-treesitter').install(opts.ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('vim-treesitter-start', { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    version = '*',
    opts = {
      on_attach = function()
        return true
      end,
    },
  },
  {
    'Wansmer/treesj',
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
    'bronson/vim-trailing-whitespace',
    cmd = { 'FixWhitespace' },
  },
  {
    'kylechui/nvim-surround',
    version = '*',
    opts = {
      keymaps = {
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
}
