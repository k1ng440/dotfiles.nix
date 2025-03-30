---@type vim.lsp.Config
return {
  cmd = { 'nixd' },
  single_file_support = true,
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
}
