return {
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
}
