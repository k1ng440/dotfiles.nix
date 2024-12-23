vim.schedule(function()
  local success, server = pcall(vim.fn.serverstart, 'fzf-lua.' .. os.time())
  if success then
    vim.g.fzf_lua_server = server
  end

  local fzf = require('fzf-lua')
  fzf.setup({
    'fzf-native',
    fzf_colors = true,
    grep = {
      previewer = 'builtin',
      rg_glob = true,
      glob_flag = '--iglob',
      glob_separator = '%s%-%-',
    },
    buffers = {
      previewer = 'builtin',
    },
    oldfiles = {
      include_current_session = true,
      stat_file = true,
      cwd_only = true,
    },
    winopts = {
      row = 1,
      col = 0,
      height = 0.4,
      width = 1,
      preview = {
        title = false,
        scrollbar = false,
        delay = 50,
      },
    },
    previewers = {
      builtin = {
        syntax = true,
        syntax_limit_b = 1024 * 100,
      },
    },
  })

  local Util = require('k1ng.util')
  local map = Util.keymap

  map('n', '<leader>sr', fzf.files, { desc = '[S]earch [R]esume' })
  map('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
  map('n', '<leader>sg', fzf.grep, { desc = '[S]earch [G]rep' })
  map('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch [W]ord' })
  map('n', '<leader>fh', fzf.oldfiles, { desc = '[S]earch Recent Files' })
  map('n', '<leader>/', fzf.buffers, { desc = '[/] Fuzzily search in current buffer' })
  map('n', '<leader>sh', fzf.helptags, { desc = 'Help Pages' })
end)
