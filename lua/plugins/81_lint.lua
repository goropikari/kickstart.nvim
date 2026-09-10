return {
  {
    'mfussenegger/nvim-lint',
    event = 'VeryLazy',
    opts = {
      events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
      linters_by_ft = {
        ['*'] = { 'gitleaks' },
        go = { 'golangcilint', 'gonextuse' },
        make = { 'checkmake' },
      },
      linters = {},
    },
    config = function(_, opts)
      local M = {}

      local lint = require('lint')
      for name, linter in pairs(opts.linters) do
        if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
          lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
          if type(linter.prepend_args) == 'table' then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters.gonextuse = function()
        local filename = vim.api.nvim_buf_get_name(0)
        local go_mod = vim.fs.find('go.mod', {
          path = vim.fs.dirname(filename),
          upward = true,
        })[1]

        return {
          cmd = 'gonextuse',
          stdin = false,
          append_fname = false,
          args = { './...' },
          stream = 'stdout',
          ignore_exitcode = true,
          cwd = go_mod and vim.fs.dirname(go_mod) or vim.fn.getcwd(),
          parser = require('lint.parser').from_pattern('^(.+):(%d+):(%d+): (.+)$', { 'file', 'lnum', 'col', 'message' }, nil, {
            severity = vim.diagnostic.severity.WARN,
          }),
        }
      end

      vim.diagnostic.config({
        virtual_text = false,
        float = {
          format = function(diagnostic)
            return 'gonextuse: ' .. diagnostic.message
          end,
        },
        virtual_lines = {
          format = function(diagnostic)
            return 'gonextuse: ' .. diagnostic.message
          end,
        },
      }, lint.get_namespace('gonextuse'))

      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)
        names = vim.list_extend({}, names)

        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft['_'] or {})
        end

        vim.list_extend(names, lint.linters_by_ft['*'] or {})

        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn('Linter not found: ' .. name, { title = 'nvim-lint' })
          end
          return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
        end, names)

        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
