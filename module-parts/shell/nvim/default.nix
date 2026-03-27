{ inputs, ... }:
{
  flake.modules.nixos.neovim =
    {
      pkgs,
      lib,
      npins,
      ...
    }:
    let
      pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

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
        blink-ripgrep = false;
        bufferline = false;
        conform = false;
        dressing = false;
        fidget = false;
        format-ts-errors = false;
        friendly-snippets = false;
        fzf-lua = false;
        git-conflict = false;
        godoc = false;
        header = false;
        inc-rename = false;
        lint = false;
        lsp-progress = false;
        lualine = false;
        luasnip = false;
        lzn = false;
        no-go = false;
        promise-async = false;
        schemastore = false;
        startuptime = false;
        todo-comments = false;
        trouble = false;
        ufo = false;
        undotree = false;
        vim-repeat = false;
        vim-speeddating = false;
        wordiff = false;
      };

      applyOptional = name: plugin: {
        inherit plugin;
        optional = optionalPlugins.${name} or false;
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

      allPlugins =
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
          vim-surround
          render-markdown-nvim
          rainbow-delimiters-nvim
          mini-indentscope
          undotree
          nvim-notify
          blink-cmp
        ]
        ++ (map (p: p.plugin) (lib.attrValues plugins));

    in
    {
      xdg.mime = {
        defaultApplications = {
          "text/plain" = "nvim.desktop";
          "text/markdown" = "nvim.desktop";
          "text/x-nix" = "nvim.desktop";
          "application/x-shellscript" = "nvim.desktop";
          "application/xml" = "nvim.desktop";
        };
        addedAssociations = {
          "text/csv" = "nvim.desktop";
        };
      };

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        package = pkgs.neovim-unwrapped;
        configure.packages.myVimPackage.start = allPlugins;
      };

      environment.systemPackages = with pkgs; [
        lua-language-server
        nil
        tree-sitter
        bash-language-server
        stylua
        shfmt
        luajitPackages.jsregexp
        vscode-langservers-extracted
        gopls
      ];

      hjem.users.k1ng.xdg.config.files = {
        "nvim".source = ./config;
      };
      # hj.files = {
      #   ".config/nvim".source = ./config;
      #   # TODO: Fix this
      #   # ".config/intelephense/license.txt".source = "${home}/nix-config/secrets/intelephense-license.txt";
      # };
    };
}
