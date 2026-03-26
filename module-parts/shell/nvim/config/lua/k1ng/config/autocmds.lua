local function augroup(name)
  return vim.api.nvim_create_augroup('nvimtrap_' .. name, { clear = true })
end


-- Display a message when the current file is not in utf-8 format.
-- Note that we need to use `unsilent` command here because of this issue:
-- https://github.com/vim/vim/issues/4379
vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*",
  group = augroup("non_utf8_file"),
  callback = function()
    if vim.bo.fileencoding ~= "utf-8" then
      vim.notify("File not in UTF-8 format!", vim.log.levels.WARN, { title = "nvim-config" })
    end
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup('no_auto_comment'),
  command = [[set formatoptions-=cro]],
})

-- Change root
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup('rooter'),
  callback = function(buf)
    local root = vim.fs.root(buf.buf, { '.git', 'Makefile', 'lazy-lock.json' })
    if root then
      vim.cmd.cd(root)
    end
  end,
})

-- Disable ColorScheme when opening large files
vim.api.nvim_create_autocmd('BufRead', {
  command = [[if getfsize(expand('%')) > 100000 | setlocal eventignore+=ColorScheme | endif]],
  group = augroup('disable_colorscheme'),
})

-- Set options for terminal
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup('term_open'),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})

-- Check if we need to reload the file when it changed
-- vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
--   group = augroup('checktime'),
--   command = 'checktime',
-- })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    vim.hl.on_yank({ higroup = "YankColor", timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'NvimTree',
    'PlenaryTestPopup',
    'Trouble',
    'checkhealth',
    'copilot',
    'dap-float',
    'fugitive',
    'help',
    'lspinfo',
    'man',
    'neo-tree',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'netrw',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('wrap_spell'),
  pattern = { 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup('auto_create_dir'),
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Auto open quickfix window
vim.api.nvim_create_autocmd({ 'QuickFixCmdPost' }, {
  group = augroup('auto_open_quickfix'),
  callback = function()
    vim.cmd('copen')
  end,
})

-- tmux reload on config change
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = augroup('tmux_reload'),
  pattern = '*tmux.conf',
  callback = function(opts)
    if vim.env.TMUX ~= nil then
      vim.fn.jobstart({ 'tmux', 'source-file', opts.file })
    end
  end,
})

-- reload config on save
vim.api.nvim_create_autocmd('BufWritePost', {
  group = augroup('config_reload'),
  pattern = {
    '**/lua/k1ng/config/*.lua',
  },
  callback = function()
    local filepath = vim.fs.normalize(vim.fn.expand('%') --[[@as string]])
    dofile(filepath)
    vim.notify('Reloaded \n' .. filepath, nil)
  end,
  desc = 'Reload config on save',
})

-- git conflict
vim.api.nvim_create_autocmd('User', {
  pattern = 'GitConflictDetected',
  callback = function()
    vim.notify('Conflict detected in ' .. vim.fn.expand('<afile>'))
  end,
})

-- Resize all windows when we resize the terminal
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("win_autoresize"),
  desc = "autoresize windows on resizing operation",
  command = "wincmd =",
})


-- Automatically reload the file if it is changed outside of Nvim, see https://unix.stackexchange.com/a/383044/221410.
-- It seems that `checktime` does not work in command line. We need to check if we are in command
-- line before executing this command, see also https://vi.stackexchange.com/a/20397/15292 .
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  pattern = "*",
  group = augroup("auto_read"),
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN, { title = "nvim-config" })
  end,
})
