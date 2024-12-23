local detail = false

return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'VimEnter' },
  command = 'Oil',
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    win_options = {
      winbar = " %{v:lua.require('oil').get_current_dir()}",
    },
    float = {
      -- Padding around the floating window
      padding = 2,
      max_width = 90,
      max_height = 0,
      -- border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
    columns = {
      'icon',
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = 'actions.select_vsplit',
      ['<C-x>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<M-p>'] = 'actions.preview',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-l>'] = false,
      ['<C-L>'] = 'actions.refresh',
      ['-'] = 'actions.parent',
      ['_'] = 'actions.open_cwd',
      ['`'] = 'actions.cd',
      ['~'] = 'actions.tcd',
      ['gs'] = 'actions.change_sort',
      ['gx'] = 'actions.open_external',
      ['g.'] = 'actions.toggle_hidden',
      ['gd'] = {
        desc = 'Toggle file detail view',
        callback = function()
          detail = not detail
          if detail then
            require('oil').set_columns({ 'permissions', 'size', 'mtime', 'icon' })
          else
            require('oil').set_columns({ 'icon' })
          end
        end,
      },
    },
    use_default_keymaps = false,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _)
        return name == '.git' or name == '..'
      end,
      win_options = {
        wrap = true,
      },
    },
  },
}
