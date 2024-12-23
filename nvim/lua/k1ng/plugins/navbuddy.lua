return {
    "SmiteshP/nvim-navbuddy",
    cmd = { "NavBuddy" },
    -- stylua: ignore
    keys = {{ '<leader>nb', function() require('nvim-navbuddy').open() end }},
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
    },
    opts = { lsp = { auto_attach = true } },
}
