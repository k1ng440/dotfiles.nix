local formatters_by_ft = {
  lua = { 'stylua' },
  astro = { 'prettierd', 'prettier', stop_after_first = true },
  javascript = { 'prettierd', 'prettier', stop_after_first = true },
  typescript = { 'prettierd', 'prettier', stop_after_first = true },
  javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
  typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
  markdown = { 'prettierd', 'prettier', stop_after_first = true },
  vue = { 'prettierd', 'prettier', stop_after_first = true },
  go = { 'goimports', 'gofumpt' },
  yaml = { 'yamlfmt' },
  json = { 'jq' },
  templ = { 'templ' },
  ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
}

return {
  {
    'stevearc/conform.nvim',
    event = 'VimEnter',
    config = function()
      require('conform').setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = {
          lsp_format = 'fallback',
          timeout_ms = 500,
        },
        notify_on_error = true,
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
    end,
  },
  {
    'zapling/mason-conform.nvim',
    dependencies = { 'stevearc/conform.nvim', 'williamboman/mason.nvim' },
  },
}
