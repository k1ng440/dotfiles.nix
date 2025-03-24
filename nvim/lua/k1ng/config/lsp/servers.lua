local M = {}

function M.get_root_dir(pattern, ...)
  local cwd = vim.fn.getcwd()
  local root_files = { ... }
  return require('lspconfig.util').root_pattern(unpack(root_files))(pattern) or cwd
end

---@type lspconfig.options
M.servers = {
  ansiblels = {},
  clangd = {
    cmd = {
      'clangd',
      '--offset-encoding=utf-16',
      '--enable-config',
    },
    root_dir = function(fname)
      local root_files = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac', -- AutoTools
      }
      return M.get_root_dir(fname, unpack(root_files))
    end,
  },
  rust_analyzer = {},
  terraformls = {},
  dockerls = {},
  helm_ls = {},
  html = {},
  ts_ls = {},
  volar = {
    root_dir = require('lspconfig').util.root_pattern('vue.config.js', 'vue.config.ts', 'nuxt.config.js', 'nuxt.config.ts'),
    filetypes = { 'vue', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json' },
  },
  intelephense = {
    root_dir = function(fname)
      local root_files = {
        'composer.json',
        'composer.lock',
        '.git',
        'phpunit.xml',
        '.php_cs',
      }
      return require('lspconfig.util').root_pattern(root_files)(fname) or vim.fn.getcwd()
    end,
    init_options = {
      licenceKey = vim.fn.expand('~/.vim/intelephense/license.txt'),
    },
    settings = {
      files = {
        maxSize = 5000000,
      },
      environment = {
        includePaths = { '~/.config/composer/vendor/php-stubs/' },
      },
      format = {
        braces = 'k&r',
      },
    },
  },
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
      redhat = {
        telemetry = {
          enabled = false,
        },
      },
    },
  },
  yamlls = {
    flags = {
      debounce_text_changes = 150,
    },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        format = { enable = true },
        schemaStore = {
          enable = false,
          url = '',
        },
        schemas = require('schemastore').yaml.schemas(),
        completion = true,
        hover = true,
      },
    },
  },
  templ = {},
  nil_ls = {},
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
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
        directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
        semanticTokens = true,
      },
    },
  },
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        hint = { enable = false },
        language = { fixIndex = false },
        completion = { callSnippet = 'Replace' },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            vim.fn.stdpath('config'),
          },
          maxPreload = 2000,
          preloadFileSize = 1000,
        },
        telemetry = { enable = false },
      },
    },
  },
  jdtls = {},
  pyright = {},
}

function M.setCapabilities(server_name, capabilities)
  M.server[server_name].capabilities = capabilities
end

function M.list()
  return vim.tbl_keys(M.servers)
end

function M.getServerConfig(server_name)
  return M.servers[server_name] or {}
end

return M
