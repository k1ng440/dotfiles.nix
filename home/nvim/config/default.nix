{
  config,
  pkgs,
  ...
}:
let
  fromGitHub = import ../functions/fromGitHub.nix;
  nvimConfigDirectory = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
  intelephenseLicenseFile = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/secrets/intelephense-license.txt";
in
{
  xdg.configFile = {
    "nvim".source = nvimConfigDirectory;
    "intelephense/license.txt".source = intelephenseLicenseFile;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
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
      (fromGitHub {
        inherit pkgs;
        rev = "d3f72beec9967eebbdcc1ad687c8826382b28b40";
        ref = "master";
        user = "alpertuna";
        repo = "vim-header";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "af61f99945e15b195fbce017230cedb0497ded4d";
        ref = "main";
        user = "mikavilpas";
        repo = "blink-ripgrep.nvim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "4bbfdd92d547d2862a75b4e80afaf30e73f7bbb4";
        ref = "main";
        user = "akinsho";
        repo = "git-conflict.nvim";
      }) # 2.1.0
      (fromGitHub {
        inherit pkgs;
        rev = "24c13df08e3fe66624bed5350a2a780f77f1f65b";
        ref = "main";
        user = "HakonHarnes";
        repo = "img-clip.nvim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "356f79853dbb3b3e200064367603751895153c29";
        ref = "main";
        user = "fredrikaverpil";
        repo = "godoc.nvim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "20128ea7158dd12df619283a45f336182b369294";
        ref = "main";
        user = "rgroli";
        repo = "other.nvim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "7d1b5c7dcd274921f0f58e90a8bf935f6a95fbf3";
        ref = "main";
        user = "rose-pine";
        repo = "neovim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "4b7418d6689bc0fd3c1db0500c67133422522384";
        ref = "main";
        user = "davidosomething";
        repo = "format-ts-errors.nvim";
      })
      (fromGitHub {
        inherit pkgs;
        rev = "87ebe7bee0b83d3b6e4f1494c74abed21b318175";
        ref = "main";
        user = "smjonas";
        repo = "inc-rename.nvim";
      })
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
}
