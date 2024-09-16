local neotest_ns = vim.api.nvim_create_namespace 'neotest'
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
      return message
    end,
  },
}, neotest_ns)

require('neotest').setup {
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
  adapters = {
    require 'neotest-go' {
      args = { '--shuffle=on' },
    },
  },
  log_level = 3,
}

-- [[ Configuration DAP ]]
local dap = require 'dap'
local dapui = require 'dapui'
local get_arguments = require('dap-go').get_arguments
require('nvim-dap-virtual-text').setup {}
require('telescope').load_extension 'dap'

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup()

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
-- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- [[ golang ]]
local function golang_dap_setup()
  require('dap-go').setup { -- Additional dap configurations can be added.
    -- delve configurations
    delve = {
      -- the path to the executable dlv which will be used for debugging.
      -- by default, this is the "dlv" executable on your PATH.
      path = 'dlv',
      -- time to wait for delve to initialize the debug session.
      -- default to 20 seconds
      initialize_timeout_sec = 20,
      -- a string that defines the port to start delve debugger.
      -- default to string "${port}" which instructs nvim-dap
      -- to start the process in a random available port
      port = '${port}',
      -- additional args to pass to dlv
      args = {},
      -- the build flags that are passed to delve.
      -- defaults to empty string, but can be used to provide flags
      -- such as "-tags=unit" to make sure the test suite is
      -- compiled during debugging, for example.
      -- passing build flags using args is ineffective, as those are
      -- ignored by delve in dap mode.
      build_flags = '',
    },
  }
  dap.adapters.delve = function(callback, config)
    callback { type = 'server', host = config.host, port = config.port }
  end
  -- dap.adapters.delve = { -- ベタ書きする方法もある
  --   type = 'server',
  --   host = '127.0.0.1',
  --   port = 8081
  -- }
end

-- [[ ruby ]]
local function ruby_dap_setup()
  require('dap-ruby').setup()
  dap.adapters.rdbg = function(callback, config)
    if config.port ~= nil then
      callback { type = 'server', host = config.host, port = config.port }
    elseif config.debugPort ~= nil then
      local t = vim.split(config.debugPort, ':')
      local host = t[1]
      local port = t[2]
      callback { type = 'server', host = host, port = port }
    else
      callback { type = 'server', host = 'localhost', port = 12345 }
    end
  end
end

-- [[  c++ ]]
local function cpp_dap_setup()
  local cpptools_path = vim.fn.stdpath 'data' .. '/mason/packages/cpptools'
  dap.adapters.cppdbg = { -- for vscode cpp debug
    id = 'cppdbg',
    type = 'executable',
    command = cpptools_path .. '/extension/debugAdapters/bin/OpenDebugAD7',
    enrich_config = function(config, on_config)
      local final_config = vim.deepcopy(config)
      -- 実行前にコンパイルする
      vim.fn.system { 'g++', '-g', '-O0', vim.fn.expand '%', '-o', vim.fn.expand '%:r' }
      on_config(final_config)
    end,
  }

  if dap.configurations.cpp == nil then
    dap.configurations.cpp = {}
  end
  for _, config in ipairs {
    {
      name = 'gdb dap build and debug (neovim)',
      type = 'cppdbg',
      request = 'launch',
      program = '${workspaceFolder}/${fileBasenameNoExtension}',
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
    },
    {
      name = 'gdb dap build and debug with args (neovim)',
      type = 'cppdbg',
      request = 'launch',
      program = '${workspaceFolder}/${fileBasenameNoExtension}',
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = get_arguments,
    },
    {
      name = 'gdb dap build and debug for competitive programming (neovim)',
      type = 'cppdbg',
      request = 'launch',
      program = '${workspaceFolder}/${fileBasenameNoExtension}',
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = { '<', 'test.txt' },
    },
  } do
    table.insert(dap.configurations.cpp, config)
  end
end

-- [[ python ]]
local function python_dap_setup()
  require('dap-python').setup()
end

-- dap adapter
local dap_adapters = {}
local langs = {
  -- { executable, dap-adapter }
  { lang = 'go', adapter = 'delve', setup = golang_dap_setup },
  { lang = 'g++', adapter = 'cpptools', setup = cpp_dap_setup },
  { lang = 'python', adapter = 'debugpy', setup = python_dap_setup },
  { lang = 'ruby', setup = ruby_dap_setup },
}
for _, config in ipairs(langs) do
  if vim.fn.executable(config.lang) == 1 and config.adapter then
    table.insert(dap_adapters, config.adapter)
  end
  config.setup()
end

-- install dap adapter
require('mason-nvim-dap').setup {
  automatic_installation = true,
  ensure_installed = dap_adapters,
}
