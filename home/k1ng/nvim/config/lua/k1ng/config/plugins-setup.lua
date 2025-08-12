-- nvim-web-devicons setup. https://github.com/nvim-tree/nvim-web-devicons
require('nvim-web-devicons').setup({})

-- Oil setup. https://github.com/stevearc/oil.nvim
-- file explorer that lets you edit your filesystem like a normal Neovim buffer.
local oil = require('oil')
local oil_detail = false

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

vim.schedule(function()
  -- bufferline.nvim setup. https://github.com/akinsho/bufferline.nvim
  -- A snazzy 💅 buffer line (with tabpage integration) for Neovim built using lua.
  require('bufferline').setup({})

  -- git-conflict.nvim. https://github.com/akinsho/git-conflict.nvim
  -- A plugin to visualise and resolve conflicts
  require('git-conflict').setup({})

  -- inc-rename. https://github.com/smjonas/inc-rename.nvim
  require('inc_rename').setup({})
  vim.keymap.set('n', 'grn', function()
    return ':IncRename ' .. vim.fn.expand('<cword>')
  end, { expr = true })
end)

-- luasnip setup
vim.schedule(function()
  require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })
  local luasnip = require('luasnip')
  local types = require('luasnip.util.types')

  local extends = {
    typescript = { 'tsdoc' },
    javascript = { 'jsdoc' },
    lua = { 'luadoc' },
    python = { 'pydoc' },
    rust = { 'rustdoc' },
    cs = { 'csharpdoc' },
    java = { 'javadoc' },
    c = { 'cdoc' },
    cpp = { 'cppdoc' },
    php = { 'phpdoc' },
    kotlin = { 'kdoc' },
    ruby = { 'rdoc' },
    sh = { 'shelldoc' },
    nix = { 'nixfmt' },
  }

  for ft, snips in pairs(extends) do
    luasnip.filetype_extend(ft, snips)
  end

  luasnip.config.set_config({
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave',
  })
  luasnip.config.setup({
    ext_opts = {
      [types.choiceNode] = {
        active = { virt_text = { { '●', 'DiagnosticHint' } } },
      },
      [types.insertNode] = {
        active = { virt_text = { { '●', 'String' } } },
      },
    },
  })
end)

-- blink.cmp setup. https://cmp.saghen.dev
-- blink.cmp is a completion plugin with support for LSPs and external sources that updates on every keystroke with minimal overhead (0.5-4ms async).
---@diagnostic disable-next-line: missing-fields
vim.schedule(function()
  require('blink.cmp').setup({
    keymap = {
      ['<return>'] = { 'accept', 'fallback' },
      ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<C-Space>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    },
    ---@diagnostic disable-next-line: missing-fields
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
      kind_icons = require('k1ng.config.icons').kinds,
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = { auto_show = false, auto_show_delay_ms = 500, window = { border = 'rounded' } },
      ghost_text = { enabled = true, show_with_menu = false },
      menu = {
        draw = {
          treesitter = { 'lsp' },
          columns = {
            { 'label', 'label_description' },
            { 'kind_icon', 'kind', gap = 1 },
          },
        },
        --   auto_show = function(ctx)
        --     return ctx.mode ~= 'cmdline' or not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
        --   end,
      },
      list = {
        selection = {
          preselect = function(ctx)
            return ctx.mode ~= 'cmdline'
          end,
        },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev', 'markdown', 'ripgrep' },
      providers = {
        lsp = {
          name = 'LSP',
          module = 'blink.cmp.sources.lsp',
          fallbacks = { 'lazydev' },
          score_offset = 200, -- the higher the number, the higher the priority
          -- Filter text items from the LSP provider, since we have the buffer provider for that
          -- transform_items = function(_, items)
          --   for _, item in ipairs(items) do
          --     if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
          --       item.score_offset = item.score_offset - 3
          --     end
          --   end
          --   return vim.tbl_filter(function(item)
          --     return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text
          --   end, items)
          -- end,
        },
        path = {
          name = 'Path',
          module = 'blink.cmp.sources.path',
          score_offset = 25,
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
          },
        },
        buffer = {
          name = 'Buffer',
          module = 'blink.cmp.sources.buffer',
          min_keyword_length = 3,
          score_offset = 15, -- the higher the number, the higher the priority
        },
        snippets = {
          name = 'Snippets',
          module = 'blink.cmp.sources.snippets',
          min_keyword_length = 2,
          score_offset = 60, -- the higher the number, the higher the priority
        },
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        markdown = { name = 'RenderMarkdown', module = 'render-markdown.integ.blink' },
        cmdline = {
          enabled = function()
            return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
          end,
        },
        ripgrep = {
          module = 'blink-ripgrep',
          name = 'Ripgrep',
          ---@module "blink-ripgrep"
          ---@type blink-ripgrep.Options
          opts = {
            prefix_min_len = 4,
            score_offset = 10, -- should be lower priority
            project_root_marker = ".git",
            fallback_to_regex_highlighting = true,
            backend = {
              use = "ripgrep",
              customize_icon_highlight = true,
              ripgrep = {
                max_filesize = "1M",
                search_casing = '--smart-case',
              }
            }
          },
        },
      },
    },
    signature = { enabled = true },
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      sorts = { 'exact', 'score', 'sort_text' },
    },
    snippets = { preset = 'luasnip' },
  })
end)

-- HakonHarnes/img-clip.nvim setup. https://github.com/HakonHarnes/img-clip.nvim
vim.schedule(function()
  require('img-clip').setup({
    default = {
      embed_image_as_base64 = false,
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      -- required for Windows users
      use_absolute_path = true,
    },
  })
end)

-- stevearc/conform.nvim setup. https://github.com/stevearc/conform.nvim
-- formatter
vim.schedule(function()
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      astro = { 'prettierd', 'prettier', stop_after_first = true },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      graphql = { 'prettierd', 'prettier', stop_after_first = true },
      vue = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      go = { 'goimports', 'gofumpt' },
      nix = { 'nix' },
      json = { 'jq' },
      templ = { 'templ' },
      svg = { 'xmlformat' },
      sql = { 'pg_format' },
      proto = { 'clang-format' },
      ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
    },
    -- format_on_save = {
    --   lsp_format = 'fallback',
    -- },
    notify_on_error = true,
    formatters = {
      nix = {
        command = 'nix',
        args = { 'fmt', '--impure', '--file', '$RELATIVE_FILEPATH' },
      },
    },
  })

  vim.api.nvim_create_user_command('Format', function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ['end'] = { args.line2, end_line:len() },
      }
    end

    require('conform').format({
      async = true,
      lsp_fallback = true,
      range = range,
    })
  end, { range = true })
  vim.keymap.set('n', '<leader>fm', '<CMD>Format<CR>', { desc = '[F]or[m]at Current Buffer' })
  vim.keymap.set({ 'n', 'i' }, '<F12>', '<CMD>Format<CR>', { desc = 'Format', silent = true })
  vim.keymap.set({ 'n', 'i' }, '<C-f>', '<CMD>Format<CR>', { desc = 'Format', silent = true })
end)

vim.schedule(function()
  -- dressing.nvim setup. https://github.com/stevearc/dressing.nvim
  require('dressing').setup({})

  -- echasnovski/mini.indentscope setup. https://github.com/echasnovski/mini.indentscope
  -- Visualize and work with indent scope
  require('mini.indentscope').setup()

  -- rainbow-delimiters setup. https://github.com/HiPhish/rainbow-delimiters.nvim
  -- Rainbow Parentheses
  require('rainbow-delimiters.setup').setup({})
end)

-- undotree setup.
vim.keymap.set('n', '<leader>ut', '<CMD>UndotreeToggle<CR>', { desc = 'Undo buffer' })

-- fidget.nvim setup. https://github.com/j-hui/fidget.nvim
-- Extensible UI for Neovim notifications and LSP progress messages.
vim.schedule(function()
  require('fidget').setup({
    notification = {
      window = {
        winblend = 0,
      },
    },
  })
end)

-- lazydev.nvim
require('lazydev').setup({
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

-- nvim-notify setup. https://github.com/rcarriga/nvim-notify
-- A fancy, configurable, notification manager for NeoVim
vim.schedule(function()
  require('notify').setup({
    ---@diagnostic disable-next-line: missing-fields
    stages = 'fade_in_slide_out',
    timeout = 2000,
    background_colour = '#1e222a',
    merge_duplicates = true,
    icons = {
      ERROR = '',
      WARN = '',
      INFO = '',
      DEBUG = '',
      TRACE = '✎',
    },
  })

  local log = require('plenary.log').new({
    plugin = 'notify',
    level = 'debug',
    use_console = false,
  })

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, level, opts)
    if msg == nil then
      return
    end

    log.info(msg, level, opts)
    if string.find(msg, 'method .* is not supported') then
      return
    end
    require('notify')(msg, level, opts)
  end
end)

-- todo-comments setup. https://github.com/folke/todo-comments.nvim
-- todo-comments is a lua plugin for Neovim >= 0.8.0 to highlight and search for todo comments like TODO, HACK, BUG in your code base.
vim.schedule(function()
  local icons = require('k1ng.config.icons').todo
  require('todo-comments').setup({
    signs = false,
    keywords = {
      FIX = { icon = icons.fix, color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'FIX', 'ISSUE' } },
      TODO = { icon = icons.todo, color = 'info', alt = { 'TODO' } },
      HACK = { icon = icons.hack, color = 'warning', alt = { 'HACK' } },
      WARN = { icon = icons.warn, color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = icons.perf, alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = icons.note, color = 'hint', alt = { 'NOTE' } },
    },
    highlight = {
      before = '',
      keyword = 'wide',
      after = 'fg',
    },
    search = {
      command = 'rg',
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
      },
      pattern = [[\b(KEYWORDS):]],
    },
  })
end)

-- treesitter.
vim.schedule(function()
  -- local parser_install_dir = os.getenv('HOME') .. '/.local/share/nvim/treesitter/parser'
  -- vim.opt.runtimepath:append(parser_install_dir)
  ---@diagnostic disable-next-line: missing-fields
  require('nvim-treesitter.configs').setup({
    sync_install = false,
    auto_install = false,
    -- parser_install_dir = parser_install_dir,
    highlight = {
      enable = true,
      disable = function(_, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true, disable = {} },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
    textobjects = {
      move = {
        enable = true,
        goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
        goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
        goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
        goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
      },
    },
  })

  -- nvim-treesitter/nvim-treesitter-textobjects
  local move = require('nvim-treesitter.textobjects.move') ---@type table<string,fun(...)>
  local configs = require('nvim-treesitter.configs')
  for name, fn in pairs(move) do
    if name:find('goto') == 1 then
      move[name] = function(q, ...)
        if vim.wo.diff then
          local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
          for key, query in pairs(config or {}) do
            if q == query and key:find('[%]%[][cC]') then
              vim.cmd('normal! ' .. key)
              return
            end
          end
        end
        return fn(q, ...)
      end
    end
  end

  -- nvim-treesitter-context. https://github.com/nvim-treesitter/nvim-treesitter-context
  require('treesitter-context').setup({
    enable = true,
    max_lines = 10,
    min_window_height = 0,
    multiline_threshold = 10,
  })
end)
-- stylua: ignore start
vim.keymap.set('n', '[c', function() require('treesitter-context').go_to_context(vim.v.count1) end, { silent = true })
-- stylua: ignore end

-- trouble.nvim setup. https://github.com/folke/trouble.nvim
-- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help you solve all the trouble your code is causing.
vim.schedule(function()
  ---@diagnostic disable-next-line: missing-fields
  require('trouble').setup({ action_keys = { open_tab = '<c-q>' } })
  -- stylua: ignore start
  vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (Trouble)' })
  vim.keymap.set('n', 'gD', '<cmd>Trouble lsp_definitions<cr>', { desc = '[G]to [D]efinitions' })
  vim.keymap.set('n', '<leader>D', '<cmd>Trouble lsp_type_definitions<cr>', { desc = 'Type [D]efinition' })
  vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
  vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
  vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
  vim.keymap.set('n', '<leader>xx', '<cmd>Trouble<cr>', { desc = 'Trouble Selector' })
  vim.keymap.set('n', '<C-t>', '<cmd>Trouble diagnostics toggle filter.severity = vim.diagnostic.severity.ERROR<cr>', { noremap = true })
  -- stylua: ignore end
end)

-- other.nvim. https://github.com/rgroli/other.nvim
vim.schedule(function()
  require('other-nvim').setup({
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
end)


vim.schedule(function ()
  local ok, render_markdown = pcall(require, "render-markdown")
  if ok then
    render_markdown .setup({
      enabled = true,
      completions = { blink = { enabled = true } },
    })
  end
end)


vim.schedule(function ()
  local ok, avante = pcall(require, 'avante')
  if ok then
    avante.setup({
      provider = "ollama",
      providers = {
        ollama = {
          endpoint = "localhost:11434",
          model = "hf.co/lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M",
          disable_tools = false,
          extra_request_body = {
            stream = true
          }
        }
      },
    })
  end
end)
