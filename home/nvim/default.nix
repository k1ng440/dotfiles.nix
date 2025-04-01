{
inputs,
pkgs,
system,
pkgs-unstable,
config,
variables,
rawNvimPlugins,
...
}: let
  normalPackages = [];
  nvimConfigDirectory = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/nvim";
  intelephenseLicenseFile = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/secrets/intelephense-license.txt";
  plugins = import ./plugins.nix { inherit inputs pkgs rawNvimPlugins; };
in {
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        plugins = plugins;
        extraPackages = [
          pkgs.bash-language-server
          pkgs.shfmt
          pkgs.goimports-reviser
          pkgs.golines
          pkgs.gopls
          pkgs.gosimports
          pkgs.htmx-lsp
          pkgs.lua-language-server
          pkgs.luaformatter
          pkgs.nixfmt-rfc-style
          pkgs.docker-compose-language-service
          pkgs.nodePackages.dockerfile-language-server-nodejs
          pkgs.nodePackages.typescript-language-server
          pkgs.nodePackages.vscode-langservers-extracted
          pkgs.nodePackages."@vue/language-server"
          pkgs.basedpyright
          pkgs.prettierd
          pkgs.pyright
          pkgs.rust-analyzer
          pkgs.rustfmt
          pkgs.svelte-language-server
          pkgs.tailwindcss-language-server
          pkgs.templ
          pkgs.terraform-ls
          pkgs.vim-language-server
          pkgs.yaml-language-server
          pkgs.python312Packages.mdformat
          pkgs.jdt-language-server
          pkgs.stylua
          pkgs.dockerfile-language-server-nodejs
          pkgs.nil
          pkgs.yamlfmt
          pkgs.chafa
          pkgs.fswatch
          pkgs.tree-sitter
          pkgs.pyright
      ];
    };
    
  # home.packages = with pkgs-unstable;
  #   [
  #     neovim
  #     tree-sitter
  #     basedpyright
  #     ruff
  #   ]
  #   ++ normalPackages;

  xdg.configFile = {
    nvim.source = config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}" + (builtins.toPath "/home/nvim/config");
    "intelephense/license.txt".source = intelephenseLicenseFile;
  };
}
