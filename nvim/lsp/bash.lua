---@type vim.lsp.Config
return {
  cmd = { "bash-language-server", "start"  },
  single_file_support = true,
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { "git" },
}
