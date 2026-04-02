_:
let
  mkKeymap = mode: key: action: {
    inherit mode key action;
    silent = true;
  };
  mkKeymapWithOpts =
    mode: key: action: opts:
    (mkKeymap mode key action) // opts;
  fzf = cmd: "function() require('fzf-lua').${cmd}() end";
in
{
  vim = {
    keymaps = [
      (mkKeymap "n" "<up>" "<nop>")
      (mkKeymap "n" "<down>" "<nop>")
      (mkKeymap "n" "<left>" "<nop>")
      (mkKeymap "n" "<right>" "<nop>")
      (mkKeymap "n" "<esc><esc>" ":nohlsearch<CR>")
      (mkKeymap "n" "-" ":Oil<CR>")
      (mkKeymapWithOpts "n" "<Tab>" "%" { desc = "Remap % to Tab"; })

      # Close buffer
      (mkKeymap "n" "<leader>ub" "<cmd>bdelete<cr>")
      (mkKeymap "n" "<leader>bd" "<Plug>BufKillBd<cr>")
      (mkKeymap "n" "<leader>bD" "<cmd>DeleteFile<cr>")

      # quit
      (mkKeymap "n" "<leader>qq" "<cmd>qa<cr>")

      # Move selection up/down/left/right
      (mkKeymap "v" "J" ":m '>+1<CR>gv=gv")
      (mkKeymap "v" "K" ":m '<-2<CR>gv=gv")
      (mkKeymap "v" ">" ">gv")
      (mkKeymap "v" "<" "<gv")
      (mkKeymap "v" "=" "=gv")

      # Copy & Paste
      (mkKeymap "v" "p" "\"_dP")
      (mkKeymap "n" "Y" "y$")

      # Buffer navigation
      (mkKeymap "n" "]b" "<cmd>bnext<CR>")
      (mkKeymap "n" "[b" "<cmd>bprev<CR>")
      (mkKeymap "n" "gn" "<cmd>bnext<CR>")
      (mkKeymap "n" "gp" "<cmd>bprev<CR>")
      (mkKeymapWithOpts "n" "<C-n>" "function() vim.cmd('bnext') print(vim.fn.expand('%:t')) end" {
        lua = true;
        desc = "Next buffer";
      })
      (mkKeymapWithOpts "n" "<C-b>" "function() vim.cmd('bprev') print(vim.fn.expand('%:t')) end" {
        lua = true;
        desc = "Prev buffer";
      })

      # Split
      (mkKeymap "n" "<leader>w-" "<C-W>s")
      (mkKeymap "n" "<leader>w|" "<C-W>v")
      (mkKeymap "n" "<leader>-" "<C-W>s")
      (mkKeymap "n" "<leader>|" "<C-W>v")

      # split navigation
      (mkKeymap "n" "<C-h>" "<cmd>wincmd h<cr>")
      (mkKeymap "n" "<C-j>" "<cmd>wincmd j<cr>")
      (mkKeymap "n" "<C-k>" "<cmd>wincmd k<cr>")
      (mkKeymap "n" "<C-l>" "<cmd>wincmd l<cr>")

      # Tab navigation
      (mkKeymap "n" "<A-l>" ":tabnext<CR>")
      (mkKeymap "n" "<A-h>" ":tabprevious<CR>")
      (mkKeymap "n" "<leader>tN" ":tabnew<CR>")
      (mkKeymap "n" "<leader>tc" ":tabclose<CR>")
      (mkKeymap "n" "<leader>tm" ":tabmove<CR>")

      # Terminal Mappings
      (mkKeymap "t" "<esc><esc>" "<c-\\><c-n>")
      (mkKeymap "t" "<C-h>" "<cmd>wincmd h<cr>")
      (mkKeymap "t" "<C-j>" "<cmd>wincmd j<cr>")
      (mkKeymap "t" "<C-k>" "<cmd>wincmd k<cr>")
      (mkKeymap "t" "<C-l>" "<cmd>wincmd l<cr>")
      (mkKeymap "t" "<C-/>" "<cmd>close<cr>")
      (mkKeymap "t" "<c-_>" "<cmd>close<cr>")

      # Quickfix
      (mkKeymap "n" "[q" "<cmd>cprev<cr>")
      (mkKeymap "n" "]q" "<cmd>cnext<cr>")
      (mkKeymap "n" "<M-j>" "<cmd>cnext<cr>")
      (mkKeymap "n" "<M-k>" "<cmd>cprev<cr>")

      # Treesitter
      (mkKeymap "n" "]f" "<cmd>TSTextobjectGotoNextStart @function.outer<cr>")
      (mkKeymap "n" "[f" "<cmd>TSTextobjectGotoPreviousStart @function.outer<cr>")
      (mkKeymap "n" "]c" "<cmd>TSTextobjectGotoNextStart @class.outer<cr>")
      (mkKeymap "n" "[c" "<cmd>TSTextobjectGotoPreviousStart @class.outer<cr>")

      # fzflua
      (mkKeymapWithOpts "n" "<leader>sr" (fzf "resume") {
        desc = "[S]earch [R]esume";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>sf" (fzf "files") {
        desc = "[S]earch [F]iles";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>sg" (fzf "live_grep") {
        desc = "[S]earch [G]rep";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>sw" (fzf "grep_cword") {
        desc = "[S]earch [W]ord";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>fh" (fzf "oldfiles") {
        desc = "[S]earch Recent Files";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>sk" (fzf "keymaps") {
        desc = "[S]earch [K]eymaps";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<C-\\>" (fzf "buffers") {
        desc = "Fuzzily search buffers";
        lua = true;
      })
      (mkKeymapWithOpts "n" "<leader>sh" (fzf "help_tags") {
        desc = "Help Pages";
        lua = true;
      })
      # Multi-mode mapping for path completion
      (mkKeymapWithOpts [ "n" "v" "i" ] "<C-x><C-f>" (fzf "complete_path") {
        desc = "Fuzzy complete path";
        lua = true;
      })
    ];

    luaConfigRC.lsp-keymaps = /* lua */ ''
      -- Helper functions for the keymaps
      local function next_diagnostic_or_trouble(is_next)
        local has_trouble, trouble = pcall(require, "trouble")
        if has_trouble and trouble.is_open() then
          if is_next then trouble.next({ skip_groups = true, jump = true })
          else trouble.prev({ skip_groups = true, jump = true }) end
        else
          if is_next then vim.diagnostic.goto_next()
          else vim.diagnostic.goto_prev() end
        end
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('nvimtrap_lsp_keymaps', { clear = true }),
        callback = function(event)
          local buffer = event.buf
          local opts = function(desc)
            return { buffer = buffer, desc = desc, silent = true }
          end

          vim.keymap.set('n', '[d', function() next_diagnostic_or_trouble(false) end, opts('LSP: Go to previous diagnostic'))
          vim.keymap.set('n', ']d', function() next_diagnostic_or_trouble(true) end, opts('LSP: Go to next diagnostic'))
          vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts('LSP: Open floating diagnostic'))
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('[G]oto [D]efinition'))
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('[G]oto [D]eclaration'))
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts('LSP: Open diagnostics list'))

          -- FzfLua integrations
          vim.keymap.set('n', '<leader>D', '<cmd>FzfLua lsp_typedefs<CR>', opts('Type [D]efinition'))
          vim.keymap.set('n', '<leader>ds', '<cmd>FzfLua lsp_document_symbols<CR>', opts('[D]ocument [S]ymbols'))
          vim.keymap.set('n', '<leader>ws', '<cmd>FzfLua lsp_workspace_symbols<CR>', opts('[W]orkspace [S]ymbols'))
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts('[W]orkspace [L]ist Folders'))
        end,
      })
    '';
  };
}
