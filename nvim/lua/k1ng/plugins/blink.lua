return {
  {
    'saghen/blink.cmp',
    dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    version = 'v0.*',
    build = 'cargo build --release',
    opts_extend = { "sources.default" },
    opts = {
      snippets = {
        expand = function(snippet)
          require('luasnip').lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require('luasnip').jumpable(filter.direction)
          end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction)
          require('luasnip').jump(direction)
        end,
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev', 'markdown' },
        completion = {
          menu = { auto_show = function(ctx) return ctx.mode ~= 'cmdline' end },
        },
        providers = {
          lsp = { fallback_for = { 'lazydev' } },
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
          markdown = { name = 'RenderMarkdown', module = 'render-markdown.integ.blink' },
        },
      },
      signature = {
        enabled = true,
      },
      keymap = {
        preset = 'default',
      },
    },
  },
}
