require('neoconf').setup({})
local Util = require('k1ng.util')
local keymap = Util.keymap
local methods = vim.lsp.protocol.Methods

local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = '',
  [vim.diagnostic.severity.WARN] = '',
  [vim.diagnostic.severity.INFO] = '',
  [vim.diagnostic.severity.HINT] = '󰌵',
}
local shorter_source_names = {
  ['Lua Diagnostics.'] = 'Lua',
  ['Lua Syntax Check.'] = 'Lua',
}
local function diagnostic_format(diagnostic)
  return string.format(
    '%s %s (%s): %s',
    diagnostic_signs[diagnostic.severity] or diagnostic.severity,
    shorter_source_names[diagnostic.source] or diagnostic.source,
    diagnostic.code,
    diagnostic.message
  )
end

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = {
    current_line = true,
    format = diagnostic_format,
    severity = vim.diagnostic.severity.WARN,
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 4,
    format = diagnostic_format,
  },
  float = { border = 'rounded' },
  signs = { text = diagnostic_signs },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))
vim.lsp.config('*', {
  root_markers = { '.git' }, -- default root markers
  capabilities = vim.tbl_deep_extend('force', capabilities, {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
      didChangeConfiguration = { dynamicRegistration = true },
    },
    textDocument = {
      foldingRange = { dynamicRegistration = true, lineFoldingOnly = true },
      semanticTokens = { multilineTokenSupport = true },
    },
  }),
})

-- Step through diagnostic messages or trouble entries if there
local next_diagnostic_or_trouble = function(forwards)
  local is_trouble_open = Util.has_buffer_in_list('Trouble')
  if is_trouble_open then
    if forwards then
      require('trouble').next({ skip_groups = true, jump = true })
    else
      require('trouble').previous({ skip_groups = true, jump = true })
    end
    return
  end
  if forwards then
    vim.diagnostic.jump({ count = 1, float = true })
  else
    vim.diagnostic.jump({ count = -1, float = true })
  end
end

local restart_lsp_servers = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local active_clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(active_clients) do
    vim.lsp.stop_client(client.id, true)
    vim.lsp.start(client.config)
  end
end

vim.api.nvim_create_user_command('LspRestart', function()
  restart_lsp_servers()
end, { force = true })

-- stylua: ignore start
keymap('n', '[d', function() next_diagnostic_or_trouble(false) end, { desc = 'LSP: Go to previous diagnostic message' })
keymap('n', ']d', function() next_diagnostic_or_trouble(true) end, { desc = 'LSP: Go to next diagnostic message' })
keymap('n', 'gl', vim.diagnostic.open_float, { desc = 'LSP: Open floating diagnostic message' })
keymap('n', 'gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
keymap('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'LSP: Open diagnostics list' })
keymap('n', '<leader>lrs', restart_lsp_servers, { desc = 'LSP: Restart' })
keymap('n', '<leader>D', '<cmd>FzfLua lsp_typedefs<CR>', 'Type [D]efinition')
keymap('n', '<leader>ds', '<cmd>FzfLua lsp_document_symbols<CR>', '[D]ocument [S]ymbols')
keymap('n', '<leader>ws', '<cmd>FzfLua lsp_workspace_symbols<CR>', '[W]orkspace [S]ymbols')
keymap('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace [L]ist Folders')
-- stylua: ignore end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp.global', { clear = true }),
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    if client:supports_method(methods.textDocument_documentHighlight) then
      local under_cursor_highlights_group = vim.api.nvim_create_augroup('lsp_cursor_highlights', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
        group = under_cursor_highlights_group,
        desc = 'Highlight references under the cursor',
        buffer = buffer,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
        group = under_cursor_highlights_group,
        desc = 'Clear highlight references',
        buffer = buffer,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Toggle the hints:
    if client:supports_method(methods.textDocument_inlayHint) then
      Util.buf_keymap(buffer, 'n', '<leader>ci', function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buffer })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = buffer })
        -- If toggling them on, turn them back off when entering insert mode.
        if not enabled then
          vim.api.nvim_create_autocmd('InsertEnter', {
            buffer = buffer,
            once = true,
            callback = function()
              vim.lsp.inlay_hint.enable(false, { bufnr = buffer })
            end,
          })
        end
      end, { desc = 'Toggle inlay hints' })
    end
  end,
})
