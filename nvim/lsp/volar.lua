---@type vim.lsp.Config
return {
  cmd = { 'vue-language-server', '--stdio' },
  init_options = {
    vue = {
      hybridMode = true,
      typescript = {
        tsdk = '',
      },
    },
  },
  filetypes = { 'vue' },
  root_markers = { 'package.json' },
}
