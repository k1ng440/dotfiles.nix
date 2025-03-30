---@type vim.lsp.Config
return {
  cmd = { 'buf', 'beta', 'lsp', '--timeout=0', '--log-format=text' },
  filetypes = { 'proto' },
  root_marker = {'buf.yaml', '.git'},
}
