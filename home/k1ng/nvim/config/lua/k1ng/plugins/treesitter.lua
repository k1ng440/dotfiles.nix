-- local parser_install_dir = os.getenv('HOME') .. '/.local/share/nvim/treesitter/parser'
-- vim.opt.runtimepath:append(parser_install_dir)
---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter').setup({
  sync_install = false,
  auto_install = false,
  -- parser_install_dir = parser_install_dir,
  additional_vim_regex_highlighting = false,
  highlight = {
    enable = true,
    -- disable = function(_, buf)
    --   local max_filesize = 100 * 1024 -- 100 KB
    --   local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    --   if ok and stats and stats.size > max_filesize then
    --     return true
    --   end
    -- end,
  },
  indent = { enable = true, disable = {} },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-space>',
      node_incremental = '<C-space>',
      scope_incremental = false,
      node_decremental = '<bs>',
    },
  },
  textobjects = {
    move = {
      enable = true,
      goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
      goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
      goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
      goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
    },
  },
})

-- nvim-treesitter/nvim-treesitter-textobjects
local move = require('nvim-treesitter-textobjects.move') ---@type table<string,fun(...)>
local configs = require('nvim-treesitter')
for name, fn in pairs(move) do
  if name:find('goto') == 1 then
    move[name] = function(q, ...)
      if vim.wo.diff then
        local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
        for key, query in pairs(config or {}) do
          if q == query and key:find('[%]%[][cC]') then
            vim.cmd('normal! ' .. key)
            return
          end
        end
      end
      return fn(q, ...)
    end
  end
end

-- nvim-treesitter-context. https://github.com/nvim-treesitter/nvim-treesitter-context
require('treesitter-context').setup({
  enable = true,
  max_lines = 10,
  min_window_height = 500,
  multiline_threshold = 10,
})

-- stylua: ignore start
vim.keymap.set('n', '[c', function() require('treesitter-context').go_to_context(vim.v.count1) end, { silent = true })
-- stylua: ignore end
