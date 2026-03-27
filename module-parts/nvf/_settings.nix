{
  pkgs,
  ...
}:
{
  # nvf options can be found at:
  # https://notashelf.github.io/nvf/options.html
  vim = {
    viAlias = true;
    vimAlias = true;
    debugMode = {
      enable = false;
      level = 16;
      logFile = "/tmp/nvf.log";
    };

    options = {
      foldlevel = 99;
      foldlevelstart = 99;
      foldcolumn = "1";
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers = {
        wl-copy = {
          enable = true;
        };
      };
    };

    theme = {
      enable = true;
      style = "main";
      name = "rose-pine";
      transparent = true;
    };

    treesitter = {
      enable = true;
      fold = true;
      indent.enable = true;
      highlight.enable = true;
      addDefaultGrammars = true;
      context.enable = true;
    };

    lsp = {
      enable = true;
      formatOnSave = false;
      lightbulb.enable = true;
      lspkind.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      otter-nvim.enable = true;
      nvim-docs-view.enable = true;
      lspSignature.enable = false;
      harper-ls.enable = true;
    };

    formatter = {
      conform-nvim.enable = true;
    };

    snippets = {
      luasnip.enable = true;
    };

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

    languages = {
      enableTreesitter = true;
      enableExtraDiagnostics = true;
      nix.enable = true;
      markdown.enable = true;
      bash.enable = true;
      python.enable = true;
      lua.enable = true;
      rust.enable = true;
      go.enable = true;
    };

    visuals = {
      indent-blankline.enable = true;
      rainbow-delimiters.enable = true;
      fidget-nvim.enable = true;
      nvim-cursorline.enable = true;
      nvim-web-devicons.enable = true;
    };

    statusline.lualine.enable = true;
    telescope.enable = false;

    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        signature.enabled = true;
        snippets.preset = "luasnip";
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        keymap = {
          preset = "default";
          "<Tab>" = [
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "fallback"
          ];
        };
        completion.documentation.auto_show = true;
      };
    };

    autopairs.nvim-autopairs.enable = true;

    ui = {
      noice.enable = true;
    };

    assistant = {
      chatgpt.enable = false;
      copilot.enable = false;
    };

    session = {
      nvim-session-manager.enable = false;
    };

    gestures = {
      gesture-nvim.enable = false;
    };

    comments = {
      comment-nvim.enable = true;
    };

    presence = {
      neocord.enable = false;
    };

    utility = {
      oil-nvim.enable = true;
      sleuth.enable = true;
    };

    mini = {
      surround.enable = true;
    };

    git = {
      enable = true;
      # git-conflict.enable = true;
      # vim-fugitive.enable = true;
      # gitsigns.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      vim-abolish = {
        package = vim-abolish;
      };
    };
  };
}
