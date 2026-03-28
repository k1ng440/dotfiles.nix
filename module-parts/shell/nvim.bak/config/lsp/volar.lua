local function get_typescript_server_path(root_dir)
  local project_root = vim.fs.dirname(vim.fs.find('node_modules', { path = root_dir, upward = true })[1])
  return project_root and (project_root .. '/node_modules/typescript/lib') or ''
end

---@type vim.lsp.Config
return {
  cmd = { 'vue-language-server', '--stdio' },
  before_init = function (params, config)
    local Util = require('k1ng.util.init')
    -- Try to use a global TypeScript Server installation
    local tsdk = Util.getNPMPrefix() .. '/lib/node_modules/typescript/lib'
    if not vim.uv.fs_stat(tsdk) then
      tsdk = get_typescript_server_path(config.root_dir)
      vim.notify('LSP: Volar is using local TypeScript', vim.log.levels.WARN)
    end

    params.initializationOptions = {
      typescript = {
        tsdk = tsdk,
        asdfg = "random shit"
      },
    }
  end,
  filetypes = { 'vue' },
  root_markers = { 'package.json' },
}
