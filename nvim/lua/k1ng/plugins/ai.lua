-- nvim-web-devicons setup. https://github.com/nvim-tree/nvim-web-devicons
require("nvim-web-devicons").setup ({ })

-- bufferline.nvim setup. https://github.com/akinsho/bufferline.nvim
-- A snazzy 💅 buffer line (with tabpage integration) for Neovim built using lua.
require("bufferline").setup({})

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
require("blink.cmp").setup({
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
    completion = {
      enabled_providers = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev', 'markdown' },
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
  }
})

-- stevearc/conform.nvim setup. https://github.comstevearc/conform.nvim
-- formatter
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
    yaml = { 'yamlfmt' },
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



