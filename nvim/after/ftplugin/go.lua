local remap = require("k1ng.util").keymap

vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4

vim.cmd([[
  compiler go
]])

-- mapping
remap("n", "<leader>;f", "<cmd>GoIfErr<cr>", "Add if err != nil check")
remap("n", "<leader>;c", "<cmd>GoCmt<cr>", "Generate doc comments")
remap("n", "<leader>;g", "<cmd>GoGenerate %<cr>", "Go generate")
remap("n", "<leader>;a", "<cmd>GoTestAdd<cr>", "Add test")
remap("n", "<leader>;A", "<cmd>GoTestsAll<cr>", "Add tests for all")
remap("n", "<leader>;e", "<cmd>GoTestsExpr<cr>", "Test expression")
remap("n", "<leader>;j", "<cmd>GoTagAdd json<cr>", "Add JSON tags")
remap("n", "<leader>;y", "<cmd>GoTagAdd yaml<cr>", "Add YAML tags")

remap("n", "<leader>td", function()
    require("dap-go").debug_test()
end, { desc = "Debug Nearest function (Go)" })
