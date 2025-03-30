local inlayHints = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

---@return string
local function getNPMPrefix()
  local handle = io.popen('npm config get prefix')
  if not handle then
    return ''
  end
  local result = handle:read('*a')
  handle:close()
  return result:gsub('^%s+', ''):gsub('%s+$', '')
end

---@type vim.lsp.Config
return {
  cmd = { 'typescript-language-server', '--stdio' },
  before_init = function(params, config)
    local vue_typescript_plugin_path = getNPMPrefix() .. '/lib/node_modules/@vue/language-server' .. '/node_modules/@vue/typescript-plugin'
    local vue_plugin_config = {}
    if vim.uv.fs_stat(vue_typescript_plugin_path) then
      vue_plugin_config = {
        {
          name = '@vue/typescript-plugin',
          location = vue_typescript_plugin_path,
          languages = { 'javascript', 'typescript', 'vue' },
        },
      }
    end

    params.initializationOptions = { plugins = vue_plugin_config }
  end,
  settings = {
    typescript = {
      inlayHints = inlayHints,
    },
    javascript = {
      inlayHints = inlayHints,
    },
  },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue' },
  root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
}
