local curl = require('plenary.curl')
local log = require('plenary.log'):new()
log.level = 'debug'

curl.post({
  url = 'http://localhost:11434/api/generate',
  stream = function(err, chunk)
    if chunk then
      local res = vim.json.decode(chunk)
      log.debug(res)
    end
  end,
  body = vim.fn.json_encode({
    model = 'llama3.2',
    prompt = 'why is the sky blue?',
  }),
})
