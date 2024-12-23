-- vim-fugitive setup.
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('__fugitive', {}),
  pattern = '*',
  callback = function()
    if vim.bo.ft ~= 'fugitive' then
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set('n', '<leader>p', function()
      vim.cmd.Git('push')
    end, opts)

    vim.keymap.set('n', '<leader>P', function()
      vim.cmd.Git('pull', '--rebase')
    end, opts)

    vim.keymap.set('n', '<leader>l', function()
      vim.cmd.Git('log')
    end, opts)

    vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
  end,
})

-- gitsigns setup. https://github.com/lewis6991/gitsigns.nvim
vim.schedule(function()
  require('gitsigns').setup({
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
      untracked = { text = '┆' },
    },
    on_attach = function(bufnr)
      vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
      vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
      vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
    end,
  })
end)
