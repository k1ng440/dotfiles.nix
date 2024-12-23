return {
    {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        config = function()
            vim.schedule(function()
                local icons = require("k1ng.config.icons").todo
                require("todo-comments").setup({
                    signs = false,
                    keywords = {
                        FIX = { icon = icons.fix, color = "error", alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" } },
                        TODO = { icon = icons.todo, color = "info", alt = { "TODO" } },
                        HACK = { icon = icons.hack, color = "warning", alt = { "HACK" } },
                        WARN = { icon = icons.warn, color = "warning", alt = { "WARNING", "XXX" } },
                        PERF = { icon = icons.perf, alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                        NOTE = { icon = icons.note, color = "hint", alt = { "NOTE" } },
                    },
                    highlight = {
                        before = "",
                        keyword = "wide",
                        after = "fg",
                    },
                    search = {
                        command = "rg",
                        args = {
                            "--color=never",
                            "--no-heading",
                            "--with-filename",
                            "--line-number",
                            "--column",
                        },
                        pattern = [[\b(KEYWORDS):]],
                    },
                })
            end)
        end,
    },
}
