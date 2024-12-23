return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "nvim-tree/nvim-web-devicons",
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            ---@class tokyonight.Config
            local opts = {
                style = "moon",
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
            require("tokyonight").setup(opts)
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
}
