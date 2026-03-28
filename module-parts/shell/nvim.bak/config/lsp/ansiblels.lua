---@type vim.lsp.Config
return {
  cmd = { 'ansible-language-server', '--stdio' },
  single_file_support = true,
  settings = {
    ansible = {
      python = {
        interpreterPath = 'python',
      },
      ansible = {
        path = 'ansible',
      },
      executionEnvironment = {
        enabled = false,
      },
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = 'ansible-lint',
        },
      },
    },
  },
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint' },
}
