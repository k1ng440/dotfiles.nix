-- Oil setup. https://github.com/stevearc/oil.nvim
-- file explorer that lets you edit your filesystem like a normal Neovim buffer.
local ok, oil = pcall(require, 'oil')
local oil_detail = false
if ok then
  oil.setup({
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
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
      ['<C-r>'] = 'actions.refresh',
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
          oil_detail = not oil_detail
          if oil_detail then
            oil.set_columns({ 'permissions', 'size', 'mtime', 'icon' })
          else
            oil.set_columns({ 'icon' })
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
  })
end
