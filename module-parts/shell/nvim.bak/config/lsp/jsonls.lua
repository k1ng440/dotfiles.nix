local ok, schemastore = pcall(require, 'schemastore')
local schemas = {}
if ok then
  schemas = schemastore.json.schemas()
end

---@type vim.lsp.Config
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  single_file_support = true,
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      schemas = schemas,
      validate = { enable = true },
    },
    redhat = {
      telemetry = { enabled = false },
    },
  },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
}
