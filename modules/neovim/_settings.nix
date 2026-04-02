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
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
      ignorecase = true;
      smartcase = true;
      undofile = true;
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
      style = "night";
      name = "tokyonight";
      transparent = true;
    };

    treesitter = {
      enable = true;
      fold = true;
      indent.enable = true;
      highlight.enable = true;
      addDefaultGrammars = true;
      context.enable = true;
      textobjects = {
        enable = true;
        setupOpts = {
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              am = "@function.outer";
              im = "@function.inner";
              ac = "@class.outer";
              ic = "@class.inner";
            };
          };
        };
      };
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
      enableDAP = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;
      markdown.enable = true;
      bash.enable = true;
      python.enable = true;
      lua.enable = true;
      rust.enable = true;
      nix = {
        enable = true;

      };
      go = {
        enable = true;
        extensions.gopher-nvim.enable = true;
      };
    };

    comments = {
      comment-nvim.enable = true;
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
      nvim-ufo.enable = true;
      borders.enable = true;
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

    presence = {
      neocord.enable = false;
    };

    utility = {
      sleuth.enable = true;
      oil-nvim = {
        enable = true;
        setupOpts = {
          confirmation = {
            border = "rounded";
          };
        };
        gitStatus = {
          enable = false;
        };
      };
    };

    mini = {
      surround.enable = true;
    };

    git = {
      enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      vim-abolish = {
        package = vim-abolish;
      };
    };

    navigation.harpoon = {
      enable = true;
      mappings = {
        markFile = "<leader>ha";
        listMarks = "<leader>hh";
        file1 = "<leader>1";
        file2 = "<leader>2";
        file3 = "<leader>3";
        file4 = "<leader>4";
      };
      setupOpts.defaults = {
        save_on_toggle = true;
        sync_on_ui_close = true;
      };
    };
  };
}
