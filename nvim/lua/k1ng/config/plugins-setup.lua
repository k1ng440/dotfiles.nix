-- nvim-web-devicons setup. https://github.com/nvim-tree/nvim-web-devicons
require('nvim-web-devicons').setup({})

-- bufferline.nvim setup. https://github.com/akinsho/bufferline.nvim
-- A snazzy 💅 buffer line (with tabpage integration) for Neovim built using lua.
require('bufferline').setup({})

-- render-markdown.nvim setup. https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Plugin to improve viewing Markdown files in Neovim
require('render-markdown').setup({})

-- gen.nvim setup. https://github.com/David-Kunz/gen.nvim
-- Generate text using LLMs with customizable prompts
require('gen').setup({
  model = 'mistral', -- The default model to use.
  quit_map = 'q', -- set keymap to close the response window
  retry_map = '<c-r>', -- set keymap to re-send the current prompt
  accept_map = '<c-cr>', -- set keymap to replace the previous selection with the last result
  host = 'localhost', -- The host running the Ollama service.
  port = '11434', -- The port on which the Ollama service is listening.
  display_mode = 'float', -- The display mode. Can be "float" or "split" or "horizontal-split".
  show_prompt = false, -- Shows the prompt submitted to Ollama.
  show_model = false, -- Displays which model you are using at the beginning of your chat session.
  no_auto_close = false, -- Never closes the window automatically.
  file = false, -- Write the payload to a temporary file to keep the command short.
  hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
  init = function(options)
    pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
  end,
  -- Function to initialize Ollama
  command = function(options)
    local body = { model = options.model, stream = true }
    return 'curl --silent --no-buffer -X POST http://' .. options.host .. ':' .. options.port .. '/api/chat -d $body'
  end,
  -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
  -- This can also be a command string.
  -- The executed command must return a JSON object with { response, context }
  -- (context property is optional).
  -- list_models = '<omitted lua function>', -- Retrieves a list of model names
  debug = false, -- Prints errors and the command which is run.
})

-- blink.cmp setup. https://cmp.saghen.dev
-- blink.cmp is a completion plugin with support for LSPs and external sources that updates on every keystroke with minimal overhead (0.5-4ms async).
---@diagnostic disable-next-line: missing-fields
vim.schedule(function()
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })

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
  }

  for ft, snips in pairs(extends) do
    require('luasnip').filetype_extend(ft, snips)
  end

  require('blink.cmp').setup({
    keymap = {
      ['<return>'] = { 'accept', 'fallback' },
      ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
    },
    ---@diagnostic disable-next-line: missing-fields
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
      kind_icons = require('k1ng.config.icons').kinds,
    },
    completion = {
      accept = { auto_brackets = { enabled = false } },
      documentation = { auto_show = false, auto_show_delay_ms = 500, window = { border = 'rounded' } },
      ghost_text = { enabled = true, show_with_menu = false },
      menu = {
        border = 'rounded',
        draw = {
          treesitter = { 'lsp' },
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
        ---@diagnostic disable-next-line: missing-fields
        lsp = {
          name = 'LSP',
          module = 'blink.cmp.sources.lsp',
          fallbacks = { 'lazydev' },
          score_offset = 200, -- the higher the number, the higher the priority
          -- Filter text items from the LSP provider, since we have the buffer provider for that
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
                item.score_offset = item.score_offset - 3
              end
            end
            return vim.tbl_filter(function(item)
              return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text
            end, items)
          end,
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
        ---@diagnostic disable-next-line: missing-fields
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
        ---@diagnostic disable-next-line: missing-fields
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
            max_filesize = '300K',
            search_casing = '--smart-case',
          },
        },
      },
    },
    ---@diagnostic disable-next-line: missing-fields
    signature = {
      enabled = true,
    },
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      sorts = {
        'exact',
        -- defaults
        'score',
        'sort_text',
      },
    },
    snippets = { preset = 'luasnip' },
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
      vue = { 'prettierd', 'prettier', stop_after_first = true },
      go = { 'goimports', 'gofumpt' },
      json = { 'jq' },
      templ = { 'templ' },
      ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
    },
    format_on_save = {
      lsp_format = 'fallback',
      timeout_ms = 500,
    },
    notify_on_error = true,
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
end)

-- Oil setup. https://github.com/stevearc/oil.nvim
-- file explorer that lets you edit your filesystem like a normal Neovim buffer.

local oil_detail = false
require('oil').setup({
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
        oil_detail = not oil_detail
        if oil_detail then
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
})

-- dressing.nvim setup. https://github.com/stevearc/dressing.nvim
vim.schedule(function()
  require('dressing').setup({})
end)

-- echasnovski/mini.indentscope setup. https://github.com/echasnovski/mini.indentscope
-- Visualize and work with indent scope
require('mini.indentscope').setup()

-- rainbow-delimiters setup. https://github.com/HiPhish/rainbow-delimiters.nvim
-- Rainbow Parentheses
require('rainbow-delimiters.setup').setup({})

-- undotree setup.
vim.keymap.set('n', '<leader>ut', '<CMD>UndotreeToggle<CR>', { desc = 'Undo buffer' })

-- nvim-navic setup. https://github.com/SmiteshP/nvim-navic
-- statusline/winbar component that uses LSP to show your current code

vim.schedule(function()
  vim.g.navic_silence = true
  local navic = require('nvim-navic')
  navic.setup({
    separator = ' ',
    highlight = true,
    depth_limit = 5,
    icons = require('k1ng.config.icons').kinds,
  })

  require('k1ng.util').on_attach(function(client, buffer)
    if client.name == 'copilot' then
      return
    end

    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, buffer)
    end
  end)
end)

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
---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
  highlight = {
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
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

-- trouble.nvim setup. https://github.com/folke/trouble.nvim
-- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help you solve all the trouble your code is causing.
---@diagnostic disable-next-line: missing-fields
require('trouble').setup({
  action_keys = { open_tab = '<c-q>' },
})

vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', 'gD', '<cmd>Trouble lsp_definitions<cr>', { desc = '[G]to [D]efinitions' })
vim.keymap.set('n', '<leader>D', '<cmd>Trouble lsp_type_definitions<cr>', { desc = 'Type [D]efinition' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble<cr>', { desc = 'Trouble Selector' })
vim.keymap.set('n', '<C-t>', '<cmd>Trouble diagnostics toggle filter.severity = vim.diagnostic.severity.ERROR<cr>', { noremap = true })
