_: {
  # Override vim.diagnostic.set — single intercept for ALL sources (nvim-lint + LSP).
  # nvim-lint calls vim.diagnostic.set directly; so does the LSP pipeline.
  # bash-ls sends code as integer 2034; nvim-lint shellcheck sends string "SC2034".
  vim.luaConfigRC.env-diag-filter = /* lua */ ''
    local _orig_diag_set = vim.diagnostic.set
    vim.diagnostic.set = function(ns, bufnr, diagnostics, opts)
      local resolved = (bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
      local name = vim.api.nvim_buf_get_name(resolved)
      local is_env = name ~= "" and (
        name:match("[/\\]?%.env$") or
        name:match("%.env%.[^/\\]+$") or
        name:match("[^/\\]+%.env$")
      )
      if is_env and diagnostics then
        diagnostics = vim.tbl_filter(function(d)
          local code = tostring(d.code or "")
          return code ~= "SC2034" and code ~= "2034"
        end, diagnostics)
      end
      _orig_diag_set(ns, bufnr, diagnostics, opts)
    end
  '';

  vim.luaConfigRC.diagnostics = /* lua */ ''
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
