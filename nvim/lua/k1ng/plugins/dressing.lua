return {
    "stevearc/dressing.nvim",
    opts = {},
    event = "BufReadPost",
    config = function(_, opts)
        vim.schedule(function()
            require("dressing").setup({})
        end)
    end,
}
