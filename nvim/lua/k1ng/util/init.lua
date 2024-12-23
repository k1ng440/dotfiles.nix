local M = {}

--- @param mode "n"|"v"|"x"|"i"|"o"|"c"|"t"|"ia"|"ca"|"!a"|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? { unique: boolean, desc: string, buffer: boolean, nowait: boolean, remap: boolean }|string
function M.keymap(mode, lhs, rhs, opts)
    local options = {
        noremap = true,
        silent = true,
    }
    if opts then
        if type(opts) == "string" then
            options.desc = opts
        elseif type(opts) == "table" then
            options = vim.tbl_extend("force", options, opts)
        end
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

--- @param bufnr number
--- @param mode "n"|"v"|"x"|"i"|"o"|"c"|"t"|"ia"|"ca"|"!a"|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? { unique: boolean, desc: string, buffer: boolean, nowait: boolean, remap: boolean }
M.buf_keymap = function(bufnr, mode, lhs, rhs, opts)
    local options = {
        buffer = bufnr,
        noremap = true,
        silent = true,
    }
    if opts then
        if type(opts) == "string" then
            options.desc = opts
        elseif type(opts) == "table" then
            options = vim.tbl_extend("force", options, opts)
        end
    end
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.autocmd(group_name, event, pattern, callback)
    local augroup = vim.api.nvim_create_augroup("core_" .. group_name, { clear = true })
    vim.api.nvim_create_autocmd(event, {
        group = augroup,
        pattern = pattern,
        callback = callback,
    })
end

-- filetype keymap
--- @param mode "n"|"v"|"x"|"i"|"o"|"c"|"t"|"ia"|"ca"|"!a"|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? { unique: boolean, desc: string, buffer: boolean, nowait: boolean, remap: boolean }
function M.ft_keymap(filetype, mode, lhs, rhs, opts)
    M.autocmd(filetype .. "_" .. mode .. "_" .. lhs, "FileType", { filetype }, function()
        M.keymap(mode, lhs, rhs, opts)
    end)
end

-- Function using buffernames to see if "Trouble" is open
function M.has_buffer_in_list(name)
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if string.match(vim.api.nvim_buf_get_name(buffer), name) then
            return true
        end
    end
    return false
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            on_attach(client, buffer)
        end,
    })
end

function M.fg(name)
    ---@type {foreground?:number}?
    local hl = vim.api.nvim_get_hl(0, { name = name })
    local fg = hl and hl.fg or hl.foreground
    return fg and { fg = string.format("#%06x", fg) }
end

---@param tbl_isnert fun(tbl, ...)
function M.tbl_insert(tbl, ...)
    local args = { ... }
    for _, v in ipairs(args) do
        table.insert(tbl, v)
    end
end

function M.config_home()
    if vim.env.XDG_CONFIG_HOME ~= nil then
        return vim.env.XDG_CONFIG_HOME
    end

    return vim.env.HOME .. "/.config"
end

function M.set_yadm_git()
    vim.b[vim.api.nvim_get_current_buf()].git_dir = vim.env.HOME .. "/.local/share/yadm/repo.git"
    if vim.fn.exists("*FugitiveDetect") ~= 0 then
        vim.fn.FugitiveDetect(vim.env.HOME .. "/.local/share/yadm/repo.git")
    end
end

return M
