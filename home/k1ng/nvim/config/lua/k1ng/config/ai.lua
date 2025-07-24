-- Avante.nvim
vim.schedule(function()
  local ok, avante = pcall(require, "avante")
  if not ok then
    return
  end

  ---@diagnostic disable-next-line: missing-fields
  avante.setup({
    -- rag_service = {
    --   enabled = true,
    --   host_mount = os.getenv("HOME"),
    --   runner = "nix",
    --   llm = {
    --     provider = "ollama",
    --     endpoint = "http://localhost:11434",
    --   }
    --
    -- }
    provider = "ollama",
    providers = {
      ollama = {
        endpoint = "http://localhost:11434",
        model = "qwen2.5-coder:14b",
        disable_tools = false,
        extra_request_body = {
          stream = true
        }
      },
      ollamalocal = {
        __inherited_from = "openai",
        api_key_name = "",
        endpoint = "http://localhost:11434/v1",
        model = "qwen2.5-coder:14b",
        mode = "legacy",
        --disable_tools = true, -- Open-source models often do not support tools.
      },
    }
  })
end)
