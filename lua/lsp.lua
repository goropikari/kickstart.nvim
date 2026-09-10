vim.env.PATH = vim.env.PATH .. ':' .. vim.fn.stdpath('data') .. '/mason/bin'

vim.diagnostic.config({
  virtual_lines = {
    format = function(diagnostic)
      return string.format('%s: %s: %s', diagnostic.source, diagnostic.code, diagnostic.message)
    end,
  },
})

vim.lsp.enable({
  'bashls',
  'buf_ls',
  'clangd',
  'docker_language_server',
  'dprint',
  'gopls',
  'lua_ls',
  'pylsp',
  'ts_ls',
  'typos_lsp',
  'yamlls',
})
