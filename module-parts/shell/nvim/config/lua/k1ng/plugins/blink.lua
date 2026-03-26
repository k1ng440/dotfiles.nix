require('blink.cmp').setup({
  keymap = {
    ['<return>'] = { 'accept', 'fallback' },
    ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
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
    default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown', 'ripgrep' },
    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        -- fallbacks = { 'lazydev' },
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
      -- lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
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
          project_root_marker = '.git',
          fallback_to_regex_highlighting = true,
          backend = {
            use = 'ripgrep',
            customize_icon_highlight = true,
            ripgrep = {
              max_filesize = '1M',
              search_casing = '--smart-case',
            },
          },
        },
      },
    },
  },
  signature = {
    enabled = true,
    trigger = {
      enabled = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert = true,
      blocked_trigger_characters = {},
    }
  },
  fuzzy = {
    implementation = 'prefer_rust_with_warning',
    sorts = { 'exact', 'score', 'sort_text' },
  },
  snippets = { preset = 'luasnip' },
})
