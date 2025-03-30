---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  single_file_support = true,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.fn.filereadable(path .. '/.luarc.json') or vim.fn.filereadable(path .. '/.luarc.jsonc') then
        return
      end
      ---@diagnostic disable-next-line: param-type-mismatch
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
    end
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
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  }
}
