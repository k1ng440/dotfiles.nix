{
  pkgs,
  rawNvimPlugins,
}:
let
  mkVimPlugin =
    name: plugin:
    pkgs.vimUtils.buildVimPlugin {
      pname = name;
      src = plugin.src;
      version = plugin.src.lastModifiedDate or "0.0.0";
    };

  builtPlugins = builtins.attrValues (builtins.mapAttrs mkVimPlugin rawNvimPlugins);

  # Merge nvim-treesitter parsers together to reduce vim.api.nvim_list_runtime_paths()
  nvim-treesitter-grammars = pkgs.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
in
with pkgs.vimPlugins;
[
  nvim-treesitter-grammars
  nvim-treesitter-textobjects
  nvim-treesitter-context
  plenary-nvim
  vim-sleuth
  vim-abolish
  vim-fugitive
  fidget-nvim
  nvim-fzf
  fzf-lua
  dressing-nvim
  gitsigns-nvim
  bufferline-nvim
  lualine-nvim
  lualine-lsp-progress
  lazydev-nvim
  luasnip
  friendly-snippets
  conform-nvim
  nvim-lint
  nui-nvim
  nvim-web-devicons
  nvim-dap
  nvim-dap-virtual-text
  nvim-dap-ui
  nvim-dap-go
  oil-nvim
  trouble-nvim
  todo-comments-nvim
  blink-cmp
  render-markdown-nvim
  mini-indentscope
  rainbow-delimiters-nvim
  undotree
  nvim-notify
  SchemaStore-nvim
  tokyonight-nvim
  vim-speeddating
  vim-abolish
]
++ builtPlugins
