{ pkgs, inputs, ... }:

let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  filteredInputNames = builtins.filter (name: builtins.match "^nvim-plugin-.*" name != null) (
    builtins.attrNames inputs
  );
  pluginPackages = builtins.map (
    name:
    unstable.vimUtils.buildVimPlugin {
      name = name;
      src = inputs.${name};
      version = inputs.${name}.locked.rev or "0.0.0";
    }
  ) filteredInputNames;
  nvim-treesitter-grammars = unstable.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
in
with unstable.vimPlugins;
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
  vim-surround
  avante-nvim
]
++ pluginPackages
