local methods = vim.lsp.protocol.Methods
local Util = require('k1ng.util')
local keymap = Util.keymap

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
    vim.diagnostic.jump( { count = 1, float = true })
  else
    vim.diagnostic.jump( { count = -1, float = true })
  end
end

-- Diagnostic keymaps
keymap('n', '[d', function()
  next_diagnostic_or_trouble(false)
end, { desc = 'LSP: Go to previous diagnostic message' })
keymap('n', ']d', function()
  next_diagnostic_or_trouble(true)
end, { desc = 'LSP: Go to next diagnostic message' })

keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'LSP: Open floating diagnostic message' })
keymap('n', 'gl', vim.diagnostic.open_float, { desc = 'LSP: Open floating diagnostic message' })

keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'LSP: Open diagnostics list' })
keymap('n', '<leader>lrs', '<cmd>LspRestart<cr>', { desc = 'LSP: Restart' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('k1ng-lsp-attach', { clear = true }),
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    local map = function(mode, lhs, rhs, desc)
      desc = desc or rhs
      local opts = { buffer = buffer, noremap = true, silent = true, desc = 'LSP: ' .. desc }
      Util.keymap(mode, lhs, rhs, opts)
    end

    local nmap = function(lhs, rhs, desc)
      map('n', lhs, rhs, desc)
    end

    local imap = function(lhs, rhs, desc)
      map('i', lhs, rhs, desc)
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gdt', '<cmd>tab split | lua vim.lsp.buf.definition()<CR>', '[G]oto [D]definition in new tab')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    nmap('grr', function()
      require('fzf-lua').lsp_references({ includeDeclaration = false })
    end, '[G]oto [R]eferences')
    nmap('gra', vim.lsp.buf.code_action, 'Code Action')
    nmap('grn', vim.lsp.buf.rename, 'Rename')
    nmap('gq', vim.diagnostic.setqflist, 'Diagnostic Quickfix list')
    imap('<C-s>', vim.lsp.buf.signature_help, 'Signature Documentation')

    nmap('gI', '<cmd>FzfLua lsp_implementations<CR>', '[G]oto [I]mplementation')
    nmap('<leader>D', '<cmd>FzfLua lsp_typedefs<CR>', 'Type [D]efinition')
    nmap('<leader>ds', '<cmd>FzfLua lsp_document_symbols<CR>', '[D]ocument [S]ymbols')
    nmap('<leader>ws', '<cmd>FzfLua lsp_workspace_symbols<CR>', '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    imap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    if client:supports_method(methods.textDocument_signatureHelp) then
      local blink_window = require('blink.cmp.completion.windows.menu')
      local blink = require('blink.cmp')

      imap('<C-k>', function()
        -- Close the completion menu first (if open).
        if blink_window.win:is_open() then
          blink.hide()
        end

        vim.lsp.buf.signature_help()
      end, 'Signature help')
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

    if client:supports_method(methods.textDocument_inlayHint) then
      nmap('<leader>ci', function()
        -- Toggle the hints:
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
      end, 'Toggle inlay hints')
    end

    local show_handler = vim.diagnostic.handlers.virtual_text.show
    assert(show_handler)
    local hide_handler = vim.diagnostic.handlers.virtual_text.hide
    vim.diagnostic.handlers.virtual_text = {
      show = function(ns, bufnr, diagnostics, opts)
        table.sort(diagnostics, function(diag1, diag2)
          return diag1.severity > diag2.severity
        end)
        return show_handler(ns, bufnr, diagnostics, opts)
      end,
      hide = hide_handler,
    }

    -- Go
    -- workaround for gopls not supporting semanticTokensProvider
    -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
    if client and client.name == 'gopls' and not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities.textDocument.semanticTokens
      client.server_capabilities.semanticTokensProvider = {
        full = true,
        ---@diagnostic disable: need-check-nil
        legend = {
          tokenTypes = semantic.tokenTypes,
          tokenModifiers = semantic.tokenModifiers,
        },
        ---@diagnostic enable: need-check-nil
        range = true,
      }
    end
  end,
})
