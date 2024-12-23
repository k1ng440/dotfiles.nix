return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog' },
    opts = function(_, opts)
      local sources = {
        'gopls',
        'golangci-lint',
        'stylua',
        'golines',
        'golangci-lint',
        'goimports_reviser',
        'gomodifytags',
        'codespell',
        'pretty-php',
        'prettierd',
        'typos',
        'yamlfmt',
      }

      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end
      for _, source in ipairs(sources) do
        table.insert(opts.ensure_installed, source)
      end
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cmd = { 'MasonToolsInstall', 'MasonToolsInstallSync', 'MasonToolsUpdate', 'MasonToolsUpdateSync', 'MasonToolsClean' },
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          'golangci-lint',
          'gopls',
          'stylua',
          'shellcheck',
          'editorconfig-checker',
          'gofumpt',
          'golines',
          'gomodifytags',
          'gotests',
          'impl',
          'json-to-struct',
          'luacheck',
          'misspell',
          'shfmt',
          'typos',
        },
      })
    end,
  },
  {
    'zapling/mason-lock.nvim',
    init = function()
      require('mason-lock').setup({
        lockfile_path = vim.fn.stdpath('config') .. '/mason-lock.json', -- (default)
      })
    end,
  },
}
