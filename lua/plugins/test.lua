return {
  {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
      'rcarriga/nvim-dap-ui',            -- Creates a beautiful debugger UI
      'theHamsta/nvim-dap-virtual-text', -- code 中に変数の値を表示する
      'nvim-telescope/telescope-dap.nvim',
      'nvim-neotest/nvim-nio',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
      'suketa/nvim-dap-ruby',
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",

      -- language adapter
      -- "nvim-neotest/neotest-go",
      {
        url = "https://github.com/wwnbb/neotest-go",
        branch = "feat/dap-support",
      },
    },
  },
}
