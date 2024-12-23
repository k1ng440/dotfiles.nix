local usercmd = function(name, cb, opts)
  return vim.api.nvim_create_user_command(name, cb, opts or {})
end

local function confirm_and_delete_buffer()
  local confirm = vim.fn.confirm('Delete buffer and file?', '&Yes\n&No', 2)

  if confirm == 1 then
    os.remove(vim.fn.expand('%'))
    vim.api.nvim_buf_delete(0, { force = true })
  end
end

usercmd('DeleteFile', confirm_and_delete_buffer, { desc = 'Delete buffer and file' })
