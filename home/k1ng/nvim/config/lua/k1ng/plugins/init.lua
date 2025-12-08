local lazy = require("k1ng.lazy")

---@param modname string
---@return function
local function rf(modname)
  return function()
    require(modname)
  end
end

local this_module = ...
---@param submodule string
local function rs(submodule, noschedule)
  if noschedule then
    return require(this_module .. "." .. submodule)
  end

  vim.schedule(function()
    require(this_module .. "." .. submodule)
  end)
end

rs('oil', true)
rs('lualine')
rs('dap')
rs('git')
rs('fzflua')
rs('lastplace')
rs('lint')
rs('blink')
rs('conform')
rs('fidget')
rs('notify')
rs('todo-comments')
rs('treesitter')
rs('trouble')
rs('render-markdown')
rs('other')
rs('devicons')
rs('lazydev')
rs('bufferline')
rs('mini')
rs('rainbow-delimiters')
rs('inc-rename',  true)
rs('img-clip')
rs('ufo', true)
rs('wordiff', true)

lazy.add_specs({
  { "startuptime", command = "StartUptime" },
})

lazy.finish()
