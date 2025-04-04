---@type vim.lsp.Config
return {
  cmd = { 'intelephense', '--stdio' },
  init_options = {
    licenceKey = vim.fn.stdpath('config') .. '/intelephense-license.txt',
  },
  settings = {
    files = { maxSize = 5000000 },
    environment = {
      includePaths = {
        '~/.config/composer/vendor/php-stubs/',
      },
    },
    format = { braces = 'k&r' },
  },
  filetypes = { 'php' },
  root_markers = { 'composer.json', 'composer.lock', '.git', 'phpunit.xml', '.php_cs' },
}
