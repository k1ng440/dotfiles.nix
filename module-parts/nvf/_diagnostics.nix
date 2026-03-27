_: {
  vim.luaConfigRC.diagnostics = ''
    vim.schedule(function()
      local diagnostic_signs = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.HINT] = '󰌵',
      }

      local shorter_source_names = {
        ['Lua Diagnostics.'] = 'Lua',
        ['Lua Syntax Check.'] = 'Lua',
      }

      local function diagnostic_format(diagnostic)
        local source = shorter_source_names[diagnostic.source] or diagnostic.source or ""
        local code = diagnostic.code and string.format(" (%s)", diagnostic.code) or ""
        local icon = diagnostic_signs[diagnostic.severity] or ""
        return string.format('%s %s%s: %s', icon, source, code, diagnostic.message)
      end

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_lines = {
          current_line = true,
          format = diagnostic_format,
          severity = vim.diagnostic.severity.INFO,
        },
        virtual_text = {
          severity = { min = vim.diagnostic.severity.INFO },
          spacing = 4,
          format = diagnostic_format,
        },
        float = {
          source = false,
          header = 'Diagnostics:',
          prefix = ' ',
          format = diagnostic_format,
          border = 'rounded',
        },
        signs = { text = diagnostic_signs },
      })
    end)

  '';
}
