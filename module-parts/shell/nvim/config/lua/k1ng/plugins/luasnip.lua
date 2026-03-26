require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })
local luasnip = require('luasnip')
local types = require('luasnip.util.types')

local extends = {
  typescript = { 'tsdoc' },
  javascript = { 'jsdoc' },
  lua = { 'luadoc' },
  python = { 'pydoc' },
  rust = { 'rustdoc' },
  cs = { 'csharpdoc' },
  java = { 'javadoc' },
  c = { 'cdoc' },
  cpp = { 'cppdoc' },
  php = { 'phpdoc' },
  kotlin = { 'kdoc' },
  ruby = { 'rdoc' },
  sh = { 'shelldoc' },
  nix = { 'nixfmt' },
}

for ft, snips in pairs(extends) do
  luasnip.filetype_extend(ft, snips)
end

luasnip.config.set_config({
  region_check_events = 'InsertEnter',
  delete_check_events = 'InsertLeave',
})
luasnip.config.setup({
  ext_opts = {
    [types.choiceNode] = {
      active = { virt_text = { { '●', 'DiagnosticHint' } } },
    },
    [types.insertNode] = {
      active = { virt_text = { { '●', 'String' } } },
    },
  },
})
