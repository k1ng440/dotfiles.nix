if vim.loader then
  vim.loader.enable()
end

local opt = vim.opt
local g = vim.g

-- Do not load lspconfig
vim.g.lspconfig = {}

g.mapleader = ' '
g.maplocalleader = ' '
g.header_field_author = "Asaduzzaman 'Asad' Pavel"
g.header_field_author_email = 'contact@iampavel.dev'
g.have_nerd_fonts = true
g.health = { style = 'float' }

opt.autowrite = false
opt.clipboard:append('unnamedplus') -- Sync with system clipboard
opt.completeopt = 'menuone,menu,noselect,noinsert,'
opt.conceallevel = 0
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 4 -- Number of spaces tabs count for
opt.softtabstop = 4 -- Number of spaces tabs count for
opt.formatoptions = 'jcroqlnt'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --with-filename --no-heading --line-number --column --hidden --smart-case --follow'
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.inccommand = 'nosplit'
opt.list = false -- Show some invisible characters (tabs...
opt.mouse = 'a' -- Enable mouse mode
-- opt.mousemodel = '' -- Disable right click menu
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 10 -- Lines of context
opt.smoothscroll = true
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize' }
opt.autoindent = false
opt.smartindent = false
opt.breakindent = true
opt.shiftround = true -- Round indent
opt.shiftwidth = 4 -- Size of an indent
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescroll = 0
opt.sidescrolloff = 3 -- Columns of context
opt.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.undodir = os.getenv('HOME') .. '/.local/share/nvim/undodir'
opt.updatetime = 100
opt.wildmode = 'longest:full,full' -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.fileencoding = 'utf-8'
opt.hidden = true
opt.lazyredraw = true
opt.title = true
opt.titlelen = 70
opt.exrc = true -- Enable local .nvimrc
opt.wrap = false -- Disable line wrap
opt.foldmethod = 'expr' -- code folding
opt.foldexpr = 'nvim_treesitter#foldexpr()' -- code folding with treesitter
opt.foldenable = false -- can be enabled directly in opened file - using 'zi' - toggle fold

opt.shortmess = opt.shortmess + 'A' -- ignore annoying swapfile messages
opt.shortmess = opt.shortmess + 'I' -- no splash screen
opt.shortmess = opt.shortmess + 'O' -- file-read message overwrites previous
opt.shortmess = opt.shortmess + 'T' -- truncate non-file messages in middle
opt.shortmess = opt.shortmess + 'W' -- don't echo "[w]"/"[written]" when writing
opt.shortmess = opt.shortmess + 'a' -- use abbreviations in messages eg. `[RO]` instead of `[readonly]`
opt.shortmess = opt.shortmess + 'c' -- completion messages
opt.shortmess = opt.shortmess + 'o' -- overwrite file-written messages
opt.shortmess = opt.shortmess + 't' -- truncate file messages at start

opt.path:append('**')
opt.wildignore:append('*/node_modules/*')
opt.wildignore:append('*/.git/*')
opt.wildignore:append('*/vendor/*')
opt.wildignore:append('*/.DS_Store')
opt.wildignore:append('*/.env')
opt.wildignore:append('*/.env.local')
opt.wildignore:append('*/.vscode/*')
opt.wildignore:append('*/.idea/*')
opt.wildignore:append('*/.gitignore')

local lspconfigs = {}
local lsp_dir = vim.fn.stdpath('config') .. '/lsp'
if vim.fn.isdirectory(lsp_dir) == 1 then
  for _, entry in ipairs(vim.fn.readdir(lsp_dir)) do
    if vim.fn.isdirectory(lsp_dir .. '/' .. entry) == 0 and entry:sub(-4) == '.lua' then
      table.insert(lspconfigs, (entry:gsub('%.lua$', '')))
    end
  end
end
vim.lsp.enable(lspconfigs)

require('k1ng.config.init')
vim.api.nvim_set_hl(0, "@go.package", { fg = "#FFD700", bold = true })
