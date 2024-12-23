return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile', 'BufEnter' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'b0o/schemastore.nvim',
      'folke/neoconf.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      require('k1ng.config.lsp')
    end,
  },
  {
    'hinell/lsp-timeout.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
  },
  {
    'olexsmir/gopher.nvim',
    build = '<cmd>GoInstallDeps<cr>',
    ft = 'go',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'SmiteshP/nvim-navic',
    event = 'LspAttach',
    opts = {
      separator = ' ',
      highlight = true,
      depth_limit = 5,
      icons = require('k1ng.config.icons').kinds,
    },
    config = function(_, opts)
      vim.schedule(function()
        vim.g.navic_silence = true
        local navic = require('nvim-navic')
        navic.setup(opts)

        require('k1ng.util').on_attach(function(client, buffer)
          if client.name == 'copilot' then
            return
          end

          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, buffer)
          end
        end)
      end)
    end,
  },
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    config = function()
      require('fidget').setup({
        notification = {
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },
  {
    'folke/neoconf.nvim',
    config = function(_, opts)
      local neoconf = require('neoconf')
      neoconf.setup(opts)
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
