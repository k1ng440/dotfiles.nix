function OilPath()
    return vim.fn.expand("%"):sub(7)
end

vim.opt_local.winbar = "%{%v:lua.OilPath()%}"
