local ok, other = pcall(require, 'other-nvim')
if ok then
  other.setup({
    mappings = {
      'golang',
      'angular',
      'laravel',
      'python',
      'react',
      'rust',
    },
  })
  -- stylua: ignore start
  vim.keymap.set("n", "<leader>ll", "<cmd>:Other<CR>", { noremap = true, silent = true, desc = "Opens the other/alternative file according to the configured mapping." })
  vim.keymap.set("n", "<leader>ltn", "<cmd>:OtherTabNew<CR>", { noremap = true, silent = true, desc = "Like :Other but opens the file in a new tab." })
  vim.keymap.set("n", "<leader>lp", "<cmd>:OtherSplit<CR>", { noremap = true, silent = true, desc = "Like :Other but opens the file in an horizontal split."  })
  vim.keymap.set("n", "<leader>lv", "<cmd>:OtherVSplit<CR>", { noremap = true, silent = true, desc = "Like :Other but opens the file in a vertical split." })
  vim.keymap.set("n", "<leader>lc", "<cmd>:OtherClear<CR>", { noremap = true, silent = true, desc = "Clears the internal reference to the other/alternative file" })
  -- stylua: ignore end
end
