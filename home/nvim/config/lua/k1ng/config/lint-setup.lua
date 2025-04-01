vim.schedule(function()
  local lint = require('lint')
  lint.linters_by_ft = {
    fish = { 'fish' },
    json = { 'jq' },
    gitcommit = { 'gitlint' },
  }

  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = vim.api.nvim_create_augroup('__lint', {}),
    callback = function()
      lint.try_lint()
    end,
  })
end)
