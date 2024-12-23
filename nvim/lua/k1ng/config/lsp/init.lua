local lspconfig = require('lspconfig')

require('neoconf').setup({})

require('k1ng.config.lsp.on_attach')

local methods = vim.lsp.protocol.Methods

local neodevstatus, neodev = pcall(require, 'neodev')
if neodevstatus then
  neodev.setup({
    library = { plugins = { 'nvim-dap-ui' }, types = true },
  })
end

-- ui
require('lspconfig.ui.windows').default_options.border = 'rounded'

-- hover
vim.lsp.handlers[methods.textDocument_hover] = vim.lsp.with(vim.lsp.handlers.hover, {
  width = 80,
  focusable = false,
})

-- publishDiagnostics
vim.lsp.handlers[methods.textDocument_publishDiagnostics] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  virtual_text = {
    prefix = '',
    spacing = 8,
  },
  signs = true,
  update_in_insert = false,
})

-- Workaround for truncating long TypeScript inlay hints.
-- TODO: Remove this if https://github.com/neovim/neovim/issues/27240 gets addressed.
local inlay_hint_handler = vim.lsp.handlers[methods.textDocument_inlayHint]
vim.lsp.handlers[methods.textDocument_inlayHint] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == 'typescript-tools' then
    result = vim.iter.map(function(hint)
      local label = hint.label ---@type string
      if label:len() >= 30 then
        label = label:sub(1, 29) .. '…'
      end
      hint.label = label
      return hint
    end, result)
  end
  inlay_hint_handler(err, result, ctx, config)
end

-- Configure vim.diagnostic
vim.diagnostic.config({
  underline = true,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
  },
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
