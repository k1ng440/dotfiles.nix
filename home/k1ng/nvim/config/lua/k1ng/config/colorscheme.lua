# nightfox-nvim
require('nightfox').setup({
  options = {
    transparent = true,
  }
});

vim.cmd("colorscheme nightfox")

-- local opts = {
--   style = 'moon',
--   transparent = true,
--   terminal_colors = true,
--   comments = { italic = true },
--   keywords = { italic = true },
--   plugins = {
--     auto = true,
--     dap = true,
--     gitsigns = true,
--     telescope = true,
--     nvimtree = true,
--     navic = true,
--     notify = true,
--     trouble = true,
--   },
-- }
-- require('tokyonight').setup(opts)
-- vim.cmd([[colorscheme tokyonight]])

vim.api.nvim_set_hl(0, "YankColor", { fg = "#ff0000", bg = "#1d1d2b", ctermfg = 59, ctermbg = 41 })
