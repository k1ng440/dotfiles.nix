require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    astro = { 'prettierd', 'prettier', stop_after_first = true },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    graphql = { 'prettierd', 'prettier', stop_after_first = true },
    vue = { 'prettierd', 'prettier', stop_after_first = true },
    css = { 'prettierd', 'prettier', stop_after_first = true },
    go = { 'goimports', 'gofumpt' },
    nix = { 'nix' },
    json = { 'jq' },
    templ = { 'templ' },
    svg = { 'xmlformat' },
    sql = { 'pg_format' },
    proto = { 'clang-format' },
    ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
  },
  -- format_on_save = {
  --   lsp_format = 'fallback',
  -- },
  notify_on_error = true,
  formatters = {
    nix = {
      command = 'nix',
      args = { 'fmt', '--impure', '--file', '$RELATIVE_FILEPATH' },
    },
  },
})

vim.api.nvim_create_user_command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end

  require('conform').format({
    async = true,
    lsp_fallback = true,
    range = range,
  })
end, { range = true })
vim.keymap.set('n', '<leader>fm', '<CMD>Format<CR>', { desc = '[F]or[m]at Current Buffer' })
vim.keymap.set({ 'n', 'i' }, '<F12>', '<CMD>Format<CR>', { desc = 'Format', silent = true })
vim.keymap.set({ 'n', 'i' }, '<C-f>', '<CMD>Format<CR>', { desc = 'Format', silent = true })
