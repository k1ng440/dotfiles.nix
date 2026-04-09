{
  pkgs,
  ...
}:
let
  helpers = import ./_helpers.nix null;
  inherit (helpers) mkKeymapWithOpts;

  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "opencode.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "nickjvandyke";
      repo = "opencode.nvim";
      rev = "main";
      hash = "sha256-b1hGZFm7HoUm/bTRy66/9+qZQ5+LgnQcWk28Hp2hkL8=";
    };
  };
in
{
  vim = {
    extraPlugins = {
      opencode-nvim = {
        package = opencode-nvim;
      };
    };

    options.autoread = true;

    luaConfigRC.opencode-opts = /* lua */ ''
      local function is_in_tmux()
        local tmux = os.getenv("TMUX")
        return tmux and tmux ~= ""
      end

      local function get_tmux_session_name()
        if not is_in_tmux() then
          return nil
        end
        local handle = io.popen("tmux display-message -p '#S' 2>/dev/null")
        if handle then
          local session_name = handle:read("*l")
          handle:close()
          if session_name and session_name ~= "" then
            return session_name
          end
        end
        return nil
      end

      local function get_opencode_port()
        local port = os.getenv("OPENCODE_PORT")
        if port and port ~= "" then
          return tonumber(port)
        end
        return nil
      end

      local opencode_port = get_opencode_port()

      vim.g.opencode_opts = {
        server = {
          port = opencode_port,
          start = function()
            vim.notify("Opencode server should be running in the right tmux pane (port: " .. (opencode_port or "auto") .. ")")
          end,
          stop = function()
            vim.notify("Opencode server is managed by tmux. Use 'tdev' to recreate the session.")
          end,
          toggle = function()
            if not is_in_tmux() then
              vim.notify("Not running inside tmux", vim.log.levels.WARN)
              return
            end
            local session_name = get_tmux_session_name()
            if not session_name then
              vim.notify("Could not get tmux session name", vim.log.levels.WARN)
              return
            end
            vim.fn.system("tmux select-pane -t " .. session_name .. ":0.1")
          end,
        },
      }

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if not opencode_port then
            vim.defer_fn(function()
              vim.notify("Opencode port not found. Run 'tdev' to start a managed session.", vim.log.levels.WARN)
            end, 1000)
          end
        end,
      })

      -- Alternative: Press <Tab> in opencode ask() to see completions manually
      -- The shadow text you're seeing is opencode's context completion (@this, @buffer, etc.)
      -- It's actually useful - just press <Tab> to complete or <Esc> to ignore

      -- Handle opencode events for better UX
      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:*",
        callback = function(args)
          local event = args.data.event

          -- Show spinner/notification when opencode is working
          if event.type == "session.request" then
            vim.g.opencode_processing = true
            vim.notify("Opencode is thinking...", vim.log.levels.INFO)
          end

          -- Clear indicator when done
          if event.type == "session.idle" then
            vim.g.opencode_processing = false
            vim.notify("Opencode finished", vim.log.levels.INFO)
          end

          -- Auto-save current buffer before opencode makes edits
          if event.type == "edit.request" then
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
              vim.cmd("write")
            end
          end
        end,
      })

      -- Auto-check for opencode edits when focus returns
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
        callback = function()
          if vim.g.opencode_processing then
            vim.cmd("checktime")
          end
        end,
      })
    '';

    keymaps = [
      (mkKeymapWithOpts [ "n" "v" ] "<leader>oa"
        /* lua */ "function() require('opencode').ask('@this: ', { submit = true }) end"
        {
          lua = true;
          desc = "[O]pencode [A]sk";
        }
      )

      (mkKeymapWithOpts [ "n" "v" ] "<leader>os" /* lua */ "function() require('opencode').select() end" {
        lua = true;
        desc = "[O]pencode [S]elect";
      })

      (mkKeymapWithOpts [ "n" "t" ] "<leader>ot" /* lua */ "function() require('opencode').toggle() end" {
        lua = true;
        desc = "[O]pencode [T]oggle";
      })

      (mkKeymapWithOpts "v" "go" /* lua */ "function() return require('opencode').operator('@this ') end" {
        lua = true;
        expr = true;
        desc = "Add range to opencode";
      })

      (mkKeymapWithOpts "n" "go" /* lua */ "function() return require('opencode').operator('@this ') end" {
        lua = true;
        expr = true;
        desc = "Add range to opencode";
      })

      (mkKeymapWithOpts "n" "goo" /* lua */ "function() return require('opencode').operator('@this ') .. '_' end" {
        lua = true;
        expr = true;
        desc = "Add line to opencode";
      })

      (mkKeymapWithOpts "n" "<leader>on" /* lua */ "function() require('opencode').command('session.new') end" {
        lua = true;
        desc = "[O]pencode [N]ew session";
      })

      (mkKeymapWithOpts "n" "<leader>ou" /* lua */ "function() require('opencode').command('session.undo') end" {
        lua = true;
        desc = "[O]pencode [U]ndo";
      })

      (mkKeymapWithOpts "n" "<leader>or" /* lua */ "function() require('opencode').command('session.redo') end" {
        lua = true;
        desc = "[O]pencode [R]edo";
      })

      (mkKeymapWithOpts [ "n" "v" ] "<leader>oe" /* lua */ "function() require('opencode').prompt('fix') end" {
        lua = true;
        desc = "[O]pencode [E]dit - Fix diagnostics";
      })

      (mkKeymapWithOpts [ "n" "v" ] "<leader>oi" /* lua */ "function() require('opencode').prompt('implement') end"
        {
          lua = true;
          desc = "[O]pencode [I]mplement";
        }
      )

      (mkKeymapWithOpts [ "n" "v" ] "<leader>oo" /* lua */ "function() require('opencode').prompt('optimize') end"
        {
          lua = true;
          desc = "[O]pencode [O]ptimize";
        }
      )

      (mkKeymapWithOpts [ "n" "v" ] "<leader>od" /* lua */ "function() require('opencode').prompt('document') end"
        {
          lua = true;
          desc = "[O]pencode [D]ocument";
        }
      )

      (mkKeymapWithOpts "n" "<leader>gc"
        /* lua */ "function() require('opencode').ask('Write a conventional commit message for @diff. Format: <type>(<scope>): <description>. Types: feat, fix, refactor, docs, style, test, chore. Keep under 72 chars: ') end"
        {
          lua = true;
          desc = "[G]it [C]ommit with opencode";
        }
      )
    ];
  };
}
