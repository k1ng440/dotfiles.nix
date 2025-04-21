vim.schedule(function()
  local has_dap, dap = pcall(require, 'dap')
  if not has_dap then
    return
  end

  --- Dap Virtual Text
  local has_dap_virtual_text, dap_virtual_text = pcall(require, 'nvim-dap-virtual-text')
  if has_dap_virtual_text then
    dap_virtual_text.setup({
      enable = true,
      enable_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,
      show_stop_reason = true,
      commented = false,
      clear_on_continue = false,
      virt_text_pos = 'inline',
    })
  end
  --- EOF Dap Virtual Text

  --- Dap UI
  local has_dapui, dapui = pcall(require, 'dapui')
  if has_dapui then
    dapui.setup()
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    --- Map K to hover while session is active.
    local api = vim.api
    local keymap_restore = {}
    dap.listeners.after['event_initialized']['me'] = function()
      for _, buf in pairs(api.nvim_list_bufs()) do
        local keymaps = api.nvim_buf_get_keymap(buf, 'n')
        for _, keymap in pairs(keymaps) do
          if keymap.lhs == 'K' then
            table.insert(keymap_restore, keymap)
            api.nvim_buf_del_keymap(buf, 'n', 'K')
          end
        end
      end
      api.nvim_set_keymap('n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
    end

    dap.listeners.after['event_terminated']['me'] = function()
      for _, keymap in pairs(keymap_restore) do
        if keymap.rhs then
          api.nvim_buf_set_keymap(keymap.buffer, keymap.mode, keymap.lhs, keymap.rhs, { silent = keymap.silent == 1 })
        elseif keymap.callback then
          vim.keymap.set(keymap.mode, keymap.lhs, keymap.callback, { buffer = keymap.buffer, silent = keymap.silent == 1 })
        end
      end
      keymap_restore = {}
    end
  end
  --- EOF Dap UI

  dap.adapters.dart = {
    type = 'executable',
    command = 'dart',
    args = { 'debug_adapter' },
  }

  dap.configurations.dart = {
    {
      type = 'dart',
      request = 'launch',
      name = 'Launch Dart',
      program = '${workspaceFolder}/lib/main.dart',
      cwd = '${workspaceFolder}',
    },
  }
end)
