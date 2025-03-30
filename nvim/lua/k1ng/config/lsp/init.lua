local lspconfig = require('lspconfig')

require('neoconf').setup({})
require('k1ng.config.lsp.on_attach')

local neodevstatus, neodev = pcall(require, 'neodev')
if neodevstatus then
  neodev.setup({
    library = { plugins = { 'nvim-dap-ui' }, types = true },
  })
end

-- ui
require('lspconfig.ui.windows').default_options.border = 'rounded'

local diagnostic_signs = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.INFO] = "",
    [vim.diagnostic.severity.HINT] = "󰌵",
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

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('blink.cmp').get_lsp_capabilities()
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles or {}
capabilities.workspace.didChangeConfiguration = capabilities.workspace.didChangeConfiguration or {}
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.foldingRange = capabilities.textDocument.foldingRange or {}

local function setup_capabilities(server, server_name)
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
  capabilities.workspace.didChangeConfiguration.dynamicRegistration = true
  capabilities.textDocument.foldingRange.dynamicRegistration = false
  capabilities.textDocument.foldingRange.lineFoldingOnly = true
  return vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
end

local servers = require('k1ng.config.lsp.servers')
for server_name, _ in pairs(servers.servers) do
  (function()
    if require('neoconf').get(server_name .. '.disable') then
      return
    end

    local server = servers.getServerConfig(server_name)
    if not server or server.enabled == false then
      return
    end

    server.capabilities = setup_capabilities(server, server_name)

    if lspconfig[server_name] then
      lspconfig[server_name].setup(server)
    else
      vim.notify('LSP server not found: ' .. server_name, vim.log.WARN)
    end
  end)()
end
