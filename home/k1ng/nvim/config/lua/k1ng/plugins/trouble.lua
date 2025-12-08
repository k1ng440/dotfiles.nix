---@diagnostic disable-next-line: missing-fields
require('trouble').setup({ action_keys = { open_tab = '<c-q>' } })
-- stylua: ignore start
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', 'gD', '<cmd>Trouble lsp_definitions<cr>', { desc = '[G]to [D]efinitions' })
vim.keymap.set('n', '<leader>D', '<cmd>Trouble lsp_type_definitions<cr>', { desc = 'Type [D]efinition' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble<cr>', { desc = 'Trouble Selector' })
vim.keymap.set('n', '<C-t>', '<cmd>Trouble diagnostics toggle filter.severity = vim.diagnostic.severity.ERROR<cr>', { noremap = true })
-- stylua: ignore end
