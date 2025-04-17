local Util = require('k1ng.util')
local map = Util.keymap

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true, desc = 'Disable <Space>' })
map('n', 'Q', '@q', { desc = 'Replay macro' })
map('n', '<Tab>', '%', { desc = 'Remap % to Tab' })

-- Close buffer
map('n', '<leader>ub', '<cmd>bdelete<cr>', { desc = '[U]nload [B]uffer' })
map('n', '<leader>bd', '<Plug>BufKillBd<cr>', { desc = '[B]buffer [D]elete' })
map('n', '<leader>bD', '<cmd>DeleteFile<cr>', { desc = 'Delete buffer and file' })

-- quit
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })

-- Tree and explorer
map({ 'n' }, '-', '<cmd>Oil<cr>', { desc = 'Oil' })
map({ 'n' }, '<leader>O', function()
  require('oil').toggle_float()
end)

-- Move selection up/down/left/right
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = '[J] Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = '[K] Move selection up' })
map('v', '>', '>gv', { desc = '[>] Indent selection' })
map('v', '<', '<gv', { desc = '[<] Unindent selection' })
map('v', '=', '=gv', { desc = '[=] Reindent selection' })

-- Copy & Paste
map('v', 'p', '"_dP', { desc = 'Paste without overwriting clipboard' })
map('n', 'Y', 'y$', { desc = 'Copy to end of line' })

-- nohlsearch
map('n', '<esc><esc>', ':nohlsearch<CR>', { desc = 'Clear highlights' })

-- Buffer navigation
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Buffer Next' })
map('n', '[b', '<cmd>bprev<CR>', { desc = 'Buffer Previous' })
map('n', 'gn', '<cmd>bnext<CR>', { desc = 'Buffer Next' })
map('n', 'gp', '<cmd>bprev<CR>', { desc = 'Buffer Previous' })

-- Split
map('n', '<leader>w-', '<C-W>s', { desc = 'Split window below' })
map('n', '<leader>w|', '<C-W>v', { desc = 'Split window right' })
map('n', '<leader>-', '<C-W>s', { desc = 'Split window below' })
map('n', '<leader>|', '<C-W>v', { desc = 'Split window right' })

-- split navigation
map('n', '<C-h>', '<cmd>wincmd h<cr>', { desc = 'Go to left window' })
map('n', '<C-j>', '<cmd>wincmd j<cr>', { desc = 'Go to lower window' })
map('n', '<C-k>', '<cmd>wincmd k<cr>', { desc = 'Go to upper window' })
map('n', '<C-l>', '<cmd>wincmd l<cr>', { desc = 'Go to right window' })

-- Tab navigation
map('n', '<A-l>', ':tabnext<CR>', { desc = 'Next tab' })
map('n', '<A-h>', ':tabprevious<CR>', { desc = 'Previous tab' })
map('n', '<leader>tN', ':tabnew<CR>', { desc = '[T]ab [N]ew' })
map('n', '<leader>tc', ':tabclose<CR>', { desc = '[T]ab [C]lose' })
map('n', '<leader>tm', ':tabmove<CR>', { desc = '[T]ab [M]ove' })

-- Terminal Mappings
map('t', '<esc><esc>', '<c-\\><c-n>', { desc = 'Enter Normal Mode' })
map('t', '<C-h>', '<cmd>wincmd h<cr>', { desc = 'Go to left window' })
map('t', '<C-j>', '<cmd>wincmd j<cr>', { desc = 'Go to lower window' })
map('t', '<C-k>', '<cmd>wincmd k<cr>', { desc = 'Go to upper window' })
map('t', '<C-l>', '<cmd>wincmd l<cr>', { desc = 'Go to right window' })
map('t', '<C-/>', '<cmd>close<cr>', { desc = 'Hide Terminal' })
map('t', '<c-_>', '<cmd>close<cr>', { desc = 'which_key_ignore' })

-- Quickfix
map('n', '<leader>cc', '<cmd>cclose<cr>Trouble close<cr>', { desc = 'Close quickfix' })
map('n', '[q', '<cmd>cprev<cr>', { desc = 'Previous quickfix' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

map('n', '<M-j>', '<cmd>cnext<cr>', { desc = 'Next quickfix' })
map('n', '<M-k>', '<cmd>cprev<cr>', { desc = 'Previous quickfix' })
