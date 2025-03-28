{pkgs, ...}:

let 
  fromGitHub = import ../functions/fromGitHub.nix;
in {
  xdg.configFile = {
    "nvim/lua".source = ./lua;
    "nvim/after".source = ./after;
    "nvim/init.lua".source = ./init.lua;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
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
      neoconf-nvim
      nui-nvim
      nvim-web-devicons
      nvim-dap
      nvim-dap-virtual-text
      nvim-dap-ui
      nvim-dap-go
      nvim-navic
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
      # (fromGitHub { inherit pkgs; rev ="6325906730330105a9adc41d0ceb8499b3072e2b"; ref="main"; user="hinell"; repo="lsp-timeout.nvim"; })
      (fromGitHub { inherit pkgs; rev ="b9721662daedd880ca0a0358cf6ffbff60617ab3"; ref="main"; user="David-Kunz"; repo="gen.nvim"; })
      (fromGitHub { inherit pkgs; rev ="d3f72beec9967eebbdcc1ad687c8826382b28b40"; ref="master"; user="alpertuna"; repo="vim-header"; })
      (fromGitHub { inherit pkgs; rev ="af61f99945e15b195fbce017230cedb0497ded4d"; ref="main"; user="mikavilpas"; repo="blink-ripgrep.nvim"; })
    ];

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
      pkgs.nodePackages.dockerfile-language-server-nodejs
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
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
}
