require('neoconf').setup({})

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
  return string.format(
    '%s %s (%s): %s',
    diagnostic_signs[diagnostic.severity] or diagnostic.severity,
    shorter_source_names[diagnostic.source] or diagnostic.source,
    diagnostic.code,
    diagnostic.message
  )
end

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = {
    current_line = true,
    format = diagnostic_format,
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 4,
    format = diagnostic_format,
  },
  float = { border = 'rounded' },
  signs = { text = diagnostic_signs },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))
vim.lsp.config('*', {
  root_markers = { '.git' }, -- default root markers
  capabilities = vim.tbl_deep_extend('force', capabilities, {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
      didChangeConfiguration = { dynamicRegistration = true },
    },
    textDocument = {
      foldingRange = { dynamicRegistration = true, lineFoldingOnly = true },
      semanticTokens = { multilineTokenSupport = true },
    },
  }),
})
