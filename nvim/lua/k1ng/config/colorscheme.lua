local opts = {
  style = 'moon',
  transparent = true,
  terminal_colors = true,
  comments = { italic = true },
  keywords = { italic = true },
  plugins = {
    auto = true,
    dap = true,
    gitsigns = true,
    telescope = true,
    nvimtree = true,
    navic = true,
    notify = true,
    trouble = true,
  },
}
require('tokyonight').setup(opts)
vim.cmd([[colorscheme tokyonight]])
