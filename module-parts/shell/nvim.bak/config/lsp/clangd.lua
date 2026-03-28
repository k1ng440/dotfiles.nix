---@type vim.lsp.Config
return {
  cmd = {
    'clangd',
    '--offset-encoding=utf-16',
    '--enable-config',
    '--clang-tidy',
    '--background-index',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { '.clangd', 'compile_commands.json' },
}
