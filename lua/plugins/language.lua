return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    'salkin-mada/openscad.nvim',
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
    'neoclide/jsonc.vim'
  },
  -- [[golang]]
  -- 'fatih/vim-go',

  -- markdown
  -- :MarkdownPreview で browser で markdown が表示される
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  }
}
