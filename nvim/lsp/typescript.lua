local Util = require('k1ng.util.init')
local inlayHints = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

local formatTsError
---@type vim.lsp.Config
return {
  cmd = { 'typescript-language-server', '--stdio' },
  handlers = {
    ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
      if result.diagnostics == nil then
        return
      end

      if not formatTsError then
        formatTsError = require("format-ts-errors")
        formatTsError.setup({
          add_markdown = true, -- wrap output with markdown ```ts ``` markers
          start_indent_level = 0, -- initial indent
        })
      end

      -- ignore some tsserver diagnostics
      local idx = 1
      while idx <= #result.diagnostics do
        local entry = result.diagnostics[idx]

        local formatter = formatTsError[entry.code]
        entry.message = formatter and formatter(entry.message) or entry.message

        -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
        if entry.code == 80001 then
          -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
          table.remove(result.diagnostics, idx)
        else
          idx = idx + 1
        end
      end

      vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
    end,
  },
  before_init = function(params, config)
    local vue_typescript_plugin_path = Util.getNPMPrefix() .. '/lib/node_modules/@vue/language-server' .. '/node_modules/@vue/typescript-plugin'
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
