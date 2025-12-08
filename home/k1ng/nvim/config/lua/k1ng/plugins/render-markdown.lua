local ok, render_markdown = pcall(require, 'render-markdown')
if ok then
  render_markdown.setup({
    enabled = true,
    completions = { blink = { enabled = true } },
  })
end
