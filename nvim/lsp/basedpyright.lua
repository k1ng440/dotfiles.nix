-- local function organize_imports()
--   local params = {
--     command = 'basedpyright.organizeimports',
--     arguments = { vim.uri_from_bufnr(0) },
--   }
--
--   local clients = util.get_lsp_clients({
--     bufnr = vim.api.nvim_get_current_buf(),
--     name = 'basedpyright',
--   })
--   for _, client in ipairs(clients) do
--     client.request('workspace/executeCommand', params, nil, 0)
--   end
-- end
--
-- local function set_python_path(path)
--   local clients = util.get_lsp_clients({
--     bufnr = vim.api.nvim_get_current_buf(),
--     name = 'basedpyright',
--   })
--   for _, client in ipairs(clients) do
--     if client.settings then
--       client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = path })
--     else
--       client.config.settings = vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
--     end
--     client.notify('workspace/didChangeConfiguration', { settings = nil })
--   end
-- end

---@type vim.lsp.Config
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
}
