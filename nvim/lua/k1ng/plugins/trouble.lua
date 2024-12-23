return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
        -- { '<leader>cc', '<cmd>Trouble close<cr>', desc = 'Close (Trouble)' },
        -- { 'gr', '<cmd>Trouble lsp_references<cr>', desc = '[G]oto [R]eferences' },
        -- { 'gd', '<cmd>Trouble lsp_definitions<cr>', desc = '[G]oto [D]efinitions' },
        { "gD", "<cmd>Trouble lsp_definitions<cr>", desc = "[G]to [D]efinitions" },
        { "<leader>D", "<cmd>Trouble lsp_type_definitions<cr>", desc = "Type [D]efinition" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        { "<leader>xx", "<cmd>Trouble<cr>", desc = "Trouble Selector" },
        {
            "<C-t>",
            "<cmd>Trouble diagnostics toggle filter.severity = vim.diagnostic.severity.ERROR<cr>",
            { noremap = true },
        },
    },
    config = function()
        require("trouble").setup({
            action_keys = { open_tab = "<c-q>" },
        })
    end,
}
