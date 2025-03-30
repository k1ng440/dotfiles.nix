vim.schedule(function()
  local success, server = pcall(vim.fn.serverstart, 'fzf-lua.' .. os.time())
  if success then
    vim.g.fzf_lua_server = server
  end

  local fzf = require('fzf-lua')
  local actions = require('fzf-lua.actions')
  fzf.setup({
    'fzf-native',
    fzf_colors = true,
    file_ignore_patterns = {
      'node_modules/',
      '.git/',
      'dist/',
      'build/',
      'target/',
      '__pycache__/',
      '%.lock',
      '%.log',
      '%.tmp',
      '%.swp',
      '%.swo',
      '%.bak',
      '%.exe',
      '%.dll',
      '%.o',
      '%.a',
      '%.so',
      '%.dylib',
      '%.jar',
      '%.class',
      '%.min.js',
      '%.min.css',
      '%.png',
      '%.jpg',
      '%.jpeg',
      '%.gif',
      '%.bmp',
      '%.svg',
      '%.ico',
      '%.pdf',
      '%.docx',
      '%.xlsx',
      '%.pptx',
    },
    actions = {
      files = {
        ['default'] = actions.file_edit,
        ['ctrl-s'] = actions.file_split,
        ['ctrl-v'] = actions.file_vsplit,
        ['ctrl-t'] = actions.file_tabedit,
        ['alt-q'] = actions.file_sel_to_qf,
      },
      buffers = {
        ['default'] = actions.buf_switch_or_edit,
        ['ctrl-d'] = actions.buf_del,
        ['ctrl-s'] = actions.buf_split,
        ['ctrl-v'] = actions.buf_vsplit,
        ['ctrl-t'] = actions.buf_tabedit,
      },
    },
    grep = {
      rg_glob = true,
      glob_flag = '--iglob',
      glob_separator = '%s%-%-',
      cwd_prompt_shorten_len = 16,
      cwd_prompt_shorten_val = 2,
    },
    files = {
      cwd_prompt_shorten_len = 16,
      cwd_prompt_shorten_val = 2,
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
        default = 'bat_native',
        title = false,
        scrollbar = false,
        delay = 50,
      },
    },
  })

  local Util = require('k1ng.util')
  local map = Util.keymap


  map('n', '<leader>sr', fzf.files, { desc = '[S]earch [R]esume' })
  map('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
  map('n', '<leader>sg', fzf.live_grep_glob, { desc = '[S]earch [G]rep' })
  map('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch [W]ord' })
  map('n', '<leader>fh', fzf.oldfiles, { desc = '[S]earch Recent Files' })
  map('n', '<C-\\>', fzf.buffers, { desc = '[/] Fuzzily search in current buffer' })
  map('n', '<leader>sh', fzf.helptags, { desc = 'Help Pages' })
  -- stylua: ignore
  map({ 'n', 'v', 'i' }, '<C-x><C-f>', fzf.complete_path, { silent = true, desc = 'Fuzzy complete path' })
end)


