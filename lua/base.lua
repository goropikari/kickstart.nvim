-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.o.shell = 'bash'
vim.o.exrc = true -- current directory の .nvim.lua を読み込む

-- tab の表示幅
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    vim.opt.expandtab = false
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua' },
  callback = function()
    vim.o.expandtab = true
    vim.o.tabstop = 2
    vim.o.shiftwidth = 2
  end,
})

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
-- 折り返された行もインデントが適用して表示される
vim.o.breakindent = true

-- Save undo history
-- vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
-- 検索時に大文字小文字を区別しない。ただし \C を付けて検索すると区別する
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
-- git の差分がある行や breakpoint の位置などを表示する列を常に表示する
vim.wo.signcolumn = 'yes'

-- Decrease update time
-- vim.o.updatetime = 250
-- vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- 折りたたみの基準
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99 -- 起動時にコードの折りたたみを無効にした状態で開く
-- vim.api.nvim_command('set nofoldenable') -- 起動時にコードの折りたたみを無効にした状態で開く

vim.opt.swapfile = false

-- VSCode の設定ファイルは jsonc として認識する
vim.filetype.add({
  filename = {
    ['devcontainer.json'] = 'jsonc',
    ['launch.json'] = 'jsonc',
    ['settings.json'] = 'jsonc',
  },
})

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
-- https://github.com/LazyVim/LazyVim/blob/12818a6cb499456f4903c5d8e68af43753ebc869/lua/lazyvim/config/options.lua#L56-L58
-- https://github.com/neovim/neovim/discussions/28010#discussioncomment-9877494
vim.opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus' -- Sync with system clipboard
local function paste()
  return {
    vim.fn.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype(''),
  }
end

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste,
  },
}

-- terminal mode を escape で抜ける
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])