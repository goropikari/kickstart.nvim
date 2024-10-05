-- viewer, prompt のバッファを作成
local viewer_buf = vim.api.nvim_create_buf(false, true)
local prompt_buf = vim.api.nvim_create_buf(false, true)

local prompt_win = -1 -- prompt ウィンドウの ID
local viewer_win = -1 -- viewer ウィンドウの ID

-- ウィンドウが非表示かどうかのフラグ
local is_windows_hidden = true

local viewer_width_ratio = 0.6
local viewer_height_ratio = 0.5

-- エディタのサイズを取得
local width = vim.api.nvim_get_option('columns') -- エディタの横幅
local height = vim.api.nvim_get_option('lines') -- エディタの縦幅

-- viewer のウィンドウのサイズを設定（横幅60%、縦幅50%）
local viewer_width = math.floor(width * viewer_width_ratio)
local viewer_height = math.floor(height * viewer_height_ratio)

-- prompt のウィンドウのサイズを設定（同じ横幅、縦幅は3行分）
local prompt_width = viewer_width
local prompt_height = 3

-- viewer のウィンドウの位置を計算（中央に配置）
local col = math.floor((width - viewer_width) / 2)
local row = math.floor((height - viewer_height) * 0.1)

-- prompt のウィンドウの位置を計算（1つ目のウィンドウの下に配置）
local row2 = row + viewer_height + 2 -- 1つ目のウィンドウの下に配置

local viewer_win_opts = {
  relative = 'editor',
  width = viewer_width,
  height = viewer_height,
  col = col,
  row = row,
  style = 'minimal',
  border = 'single',
}

local prompt_win_opts = {
  relative = 'editor',
  width = prompt_width,
  height = prompt_height,
  col = col,
  row = row2,
  style = 'minimal',
  border = 'single',
}

local function send_to_echo_server(data)
  local url = 'http://127.0.0.1:8080' -- echo サーバーの URL
  local command = string.format("curl -s -X GET -d '%s' %s", data, url)

  -- コマンドを実行し、レスポンスを取得
  local handle = io.popen(command)
  if handle then
    local response = handle:read('*a') -- 全ての出力を読み込む
    handle:close()
    return response
  end

  return nil
end

local function send_prompt_to_viewer(prompt_buf, viewer_buf)
  -- prompt の内容を取得
  local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false)
  local data = table.concat(lines, '\n')

  local response = {}
  if data then
    response = vim.split(send_to_echo_server(data), '\n')
  end

  -- viewer に prompt の内容を追加
  vim.api.nvim_buf_set_lines(viewer_buf, -1, -1, false, response)

  -- prompt の内容をクリア
  vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, {})
end

-- prompt の挿入モードで CTRL-ENTER が押されたら prompt の内容を viewer に送り、prompt の内容を消す
vim.api.nvim_buf_set_keymap(prompt_buf, 'i', '<C-CR>', '', {
  noremap = true,
  silent = true,
  callback = function()
    send_prompt_to_viewer(prompt_buf, viewer_buf)
  end,
})

-- windows だと <c-cr> が何故か効かない
vim.api.nvim_buf_set_keymap(prompt_buf, 'i', '<c-s>', '', {
  noremap = true,
  silent = true,
  callback = function()
    send_prompt_to_viewer(prompt_buf, viewer_buf)
  end,
})

-- 非表示のウィンドウを再表示する関数
local function show_windows()
  if is_windows_hidden then
    -- viewer ウィンドウを再表示
    viewer_win = vim.api.nvim_open_win(viewer_buf, false, viewer_win_opts)

    -- prompt ウィンドウを再表示
    prompt_win = vim.api.nvim_open_win(prompt_buf, true, prompt_win_opts)

    is_windows_hidden = false -- ウィンドウが再表示されたことを記録
  end
end

-- <leader>o でウィンドウを再表示する
vim.api.nvim_set_keymap('n', '<leader>o', '', {
  noremap = true,
  silent = true,
  callback = show_windows,
})

local function hide_windows()
  if not is_windows_hidden then
    vim.api.nvim_win_hide(prompt_win)
    vim.api.nvim_win_hide(viewer_win)
    is_windows_hidden = true
  end
end

-- <ESC> でウィンドウを非表示にする
vim.api.nvim_buf_set_keymap(prompt_buf, 'n', '<Esc>', '', {
  noremap = true,
  silent = true,
  callback = hide_windows,
})
vim.api.nvim_buf_set_keymap(prompt_buf, 'n', 'q', '', {
  noremap = true,
  silent = true,
  callback = hide_windows,
})
vim.api.nvim_buf_set_keymap(viewer_buf, 'n', '<Esc>', '', {
  noremap = true,
  silent = true,
  callback = hide_windows,
})
vim.api.nvim_buf_set_keymap(viewer_buf, 'n', 'q', '', {
  noremap = true,
  silent = true,
  callback = hide_windows,
})

show_windows()
