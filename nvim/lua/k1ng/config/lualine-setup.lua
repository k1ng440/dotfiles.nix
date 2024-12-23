vim.schedule(function()
  local Util = require('k1ng.util')
  local navic = require('nvim-navic')
  local icons = require('k1ng.config.icons')

  local colors = {
    [''] = Util.fg('Special'),
    ['Normal'] = Util.fg('Special'),
    ['Warning'] = Util.fg('DiagnosticError'),
    ['InProgress'] = Util.fg('DiagnosticWarn'),
  }

  local opts = {
    options = {
      theme = 'tokyonight',
      globalstatus = true,
      disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'NvimTree', 'lazy', 'oil' } },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff' },
      lualine_c = {
        {
          'diagnostics',
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
        {
          'filetype',
          icon_only = true,
          separator = '',
          padding = {
            left = 1,
            right = 0,
          },
        },
        {
          'filename',
          path = 1,
          shorting_target = 40,
          symbols = { modified = '  ', readonly = '', unnamed = '' },
        },
        {
          function()
            return navic.get_location()
          end,
          cond = function()
            return navic.is_available()
          end,
        },
      },
      lualine_x = {
        {
          function()
            local status = require('copilot.api').status.data
            return icons.kinds.Copilot .. (status.message or '')
          end,
          cond = function()
            if not package.loaded['copilot'] then
              return
            end
            local ok, clients = pcall(vim.lsp.get_clients, { name = 'copilot', bufnr = 0 })
            return ok and #clients > 0
          end,
          color = function()
            if not package.loaded['copilot'] then
              return
            end
            local status = require('copilot.api').status.data
            return colors[status.status] or colors['']
          end,
        },
        {
          function()
            return '  ' .. require('dap').status()
          end,
          cond = function()
            return package.loaded['dap'] and require('dap').status() ~= ''
          end,
        },
        {
          'diff',
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
        },
      },
      lualine_y = {
        { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
        { 'location', padding = { left = 0, right = 1 } },
      },
      lualine_z = {
        function()
          return '  ' .. os.date('%R')
        end,
      },
    },
    extensions = { 'lazy' },
  }
  require('lualine').setup(opts)
end)
