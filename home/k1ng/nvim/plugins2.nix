{
  npins,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  makePluginFromPin =
    name: pin:
    pkgs.vimUtils.buildVimPlugin {
      pname = name;
      version = pin.version or pin.revision;
      src = pin;
      doCheck = false;
    };
  optionalPlugins = {
    gitsigns = false;
    oil = false;
    nightfox = false;
  };
  applyOptional = name: plugin: {
    inherit plugin;
    optional =
      optionalPlugins.${name}
        or (lib.warn "${name} has no explicit optionality, assuming mandatory status" false);
  };
  plugins = lib.pipe npins [
    (lib.filterAttrs (name: _: lib.hasPrefix "nvim-" name))
    (lib.mapAttrs' (name: pin: lib.nameValuePair (lib.removePrefix "nvim-" name) pin))
    (lib.mapAttrs makePluginFromPin)
    (lib.mapAttrs applyOptional)
  ];
  nvim-treesitter-grammars = pkgsUnstable.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
in
with pkgsUnstable.vimPlugins;
[
  plenary-nvim
  nvim-treesitter-grammars
  nvim-treesitter-textobjects
  nvim-treesitter-context
  nvim-web-devicons
  nvim-dap
  nvim-dap-virtual-text
  nvim-dap-ui
  nvim-dap-go
  vim-sleuth
  vim-abolish
  vim-fugitive
  vim-abolish
  vim-surround
  nvim-fzf
  fzf-lua
  nui-nvim
  nvim-dap
  nvim-dap-virtual-text
  nvim-dap-ui
  nvim-dap-go
  render-markdown-nvim
  rainbow-delimiters-nvim
  mini-indentscope
  undotree
  nvim-notify
  blink-cmp
]
++ lib.attrValues plugins
