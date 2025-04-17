-- Disable some builtin vim plugins
local disabled_built_ins = {
  '2html_plugin',
  'getscript',
  'getscriptPlugin',
  'gzip',
  'logipat',
  'tar',
  'tarPlugin',
  'rrhelper',
  'vimball',
  'vimballPlugin',
  'zip',
  'zipPlugin',
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
