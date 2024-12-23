return {
  { 'tpope/vim-surround' },
  { 'tpope/vim-sleuth' },
  {
    'echasnovski/mini.indentscope',
    event = 'BufReadPost',
    config = function()
      vim.schedule(function()
        require('mini.indentscope').setup({
          highlight_on_key = true,
          dim = true,
          symbol = '│',
        })
      end)
    end,
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = 'BufReadPost',
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>ut', '<cmd>UndotreeToggle<CR>', desc = '[U]ndo [T]ree' } },
  },
}
