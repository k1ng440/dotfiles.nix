---@type vim.lsp.Config
return {
  cmd = { 'gopls' },
  settings = {
    gopls = {
      gofumpt = false,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = false,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules', '-dist', },
      semanticTokens = true,
    },
  },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  single_file_support = true,
  root_markers = { 'go.work', 'go.mod', '.git' },
}
