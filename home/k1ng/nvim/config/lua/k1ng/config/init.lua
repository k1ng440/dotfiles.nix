require('k1ng.config.colorscheme')
require('k1ng.config.autocmds')
require('k1ng.config.usercmds')
require('k1ng.config.disable-bultin')
require('k1ng.config.keymaps')
require('k1ng.config.lastplace')
require('k1ng.config.filetypes')

if vim.fn.has('0.11.0') == 1 then
  require('k1ng.config.lsp-setup')
  require('k1ng.config.lint-setup')
end

--- plugins
require('k1ng.config.plugins-setup')
require('k1ng.config.fzflua-setup')
require('k1ng.config.git-setup')
require('k1ng.config.lualine-setup')
