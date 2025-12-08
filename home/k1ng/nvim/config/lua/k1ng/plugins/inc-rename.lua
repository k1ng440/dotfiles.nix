-- inc-rename. https://github.com/smjonas/inc-rename.nvim
require('k1ng.lazy').add_specs({
  {
    'inc-rename',
    after = function()
      require('inc_rename').setup({})
    end,
    keys = {
      {
        'grn',  function ()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end
      },
    },
  }
})

