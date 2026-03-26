local ok, schemastore = pcall(require, 'schemastore')
local schemas = {}
if ok then
  schemas = schemastore.json.schemas()
end

---@type vim.lsp.Config
return {
  cmd = { 'yaml-language-server', '--stdio' },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
      schemaStore = { enable = false, url = '' },
      schemas = schemas,
      completion = true,
      hover = true,
    },
  },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
  root_markers = { '.git' },
}
