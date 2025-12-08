local ok, lazydev = pcall(require, 'lazydev')
if ok then
  lazydev.setup({
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  })
end
