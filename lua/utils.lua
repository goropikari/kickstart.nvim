local M = {}

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
function M.find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print('Not a git repository. Searching on current working directory')
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
function M.live_grep_git_root()
  local git_root = M.find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

-- 選択した行を取得する
---@return table<string>
function M.get_visual_lines(opts)
  if vim.fn.mode() == 'n' then -- command から使う用
    local res = vim.fn.getline(opts.line1, opts.line2)
    if type(res) == 'string' then
      res = { res }
    end
    return res
  else -- <leader> key を使った keymap 用
    local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
    -- https://github.com/neovim/neovim/discussions/26092
    vim.cmd([[ execute "normal! \<ESC>" ]])
    return lines
  end
end

function M.show_visual_lines(opts)
  print(vim.fn.join(M.get_visual_lines(opts) or {}, '\n'))
end

-- vim.api.nvim_create_user_command('ShowVisualLines', function(opts)
--   show_visual_lines(opts)
-- end, {
--   range = 0, -- これを入れないと No range allowed というエラーが出る
-- })

return M
