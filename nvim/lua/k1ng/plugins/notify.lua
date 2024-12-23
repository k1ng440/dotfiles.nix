return {
    {
        "rcarriga/nvim-notify",
        event = "VimEnter",
        config = function()
            require("notify").setup({
                stages = "fade_in_slide_out",
                timeout = 2000,
                background_colour = "#1e222a",
                icons = {
                    ERROR = "",
                    WARN = "",
                    INFO = "",
                    DEBUG = "",
                    TRACE = "✎",
                },
            })

            local log = require("plenary.log").new({
                plugin = "notify",
                level = "debug",
                use_console = false,
            })

            ---@diagnostic disable-next-line: duplicate-set-field
            vim.notify = function(msg, level, opts)
                if msg == nil then
                    return
                end

                log.info(msg, level, opts)
                if string.find(msg, "method .* is not supported") then
                    return
                end
                require("notify")(msg, level, opts)
            end
        end,

        cond = function()
            if not pcall(require, "plenary") then
                return false
            end
            return true
        end,
    },
}
