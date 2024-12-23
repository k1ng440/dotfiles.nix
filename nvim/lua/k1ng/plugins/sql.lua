return {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
        { "tpope/vim-dadbod" },
        {
            "kristijanhusak/vim-dadbod-completion",
            dependencies = {
                "hrsh7th/nvim-cmp",
                "hrsh7th/cmp-buffer",
            },
            ft = { "sql", "mysql", "plsql" },
            after = "vim-dadbod",
            config = function()
                local cmp = require("cmp")
                cmp.setup.filetype({ "sql" }, {
                    sources = {
                        { name = "vim-dadbod-completion" },
                        { name = "buffer" },
                    },
                })
            end,
        },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
        vim.g.db_ui_use_nerd_fonts = 1
    end,
}
