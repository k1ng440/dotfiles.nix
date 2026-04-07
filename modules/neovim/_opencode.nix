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
      local function get_opencode_port()
        -- Read from /tmp using session name derived from cwd
        local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        local f = io.open("/tmp/.opencode.port." .. session_name, "r")
        if f then
          local port = f:read("*n")
          f:close()
          return port
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
            vim.fn.system("tmux select-pane -t " .. vim.fn.getcwd() .. ":0.1")
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
    '';

    keymaps = [
      (mkKeymapWithOpts [ "n" "v" ] "<leader>oa"
        "function() require('opencode').ask('@this: ', { submit = true }) end"
        {
          lua = true;
          desc = "[O]pencode [A]sk";
        }
      )

      (mkKeymapWithOpts [ "n" "v" ] "<leader>os" "function() require('opencode').select() end" {
        lua = true;
        desc = "[O]pencode [S]elect";
      })

      (mkKeymapWithOpts [ "n" "t" ] "<leader>ot" "function() require('opencode').toggle() end" {
        lua = true;
        desc = "[O]pencode [T]oggle";
      })

      (mkKeymapWithOpts "v" "go" "function() return require('opencode').operator('@this ') end" {
        lua = true;
        expr = true;
        desc = "Add range to opencode";
      })

      (mkKeymapWithOpts "n" "go" "function() return require('opencode').operator('@this ') end" {
        lua = true;
        expr = true;
        desc = "Add range to opencode";
      })

      (mkKeymapWithOpts "n" "goo" "function() return require('opencode').operator('@this ') .. '_' end" {
        lua = true;
        expr = true;
        desc = "Add line to opencode";
      })

      (mkKeymapWithOpts "n" "<S-C-u>" "function() require('opencode').command('session.half.page.up') end"
        {
          lua = true;
          desc = "Scroll opencode up";
        }
      )

      (mkKeymapWithOpts "n" "<S-C-d>"
        "function() require('opencode').command('session.half.page.down') end"
        {
          lua = true;
          desc = "Scroll opencode down";
        }
      )

      (mkKeymapWithOpts "n" "<leader>on" "function() require('opencode').command('session.new') end" {
        lua = true;
        desc = "[O]pencode [N]ew session";
      })

      (mkKeymapWithOpts "n" "<leader>ou" "function() require('opencode').command('session.undo') end" {
        lua = true;
        desc = "[O]pencode [U]ndo";
      })

      (mkKeymapWithOpts "n" "<leader>or" "function() require('opencode').command('session.redo') end" {
        lua = true;
        desc = "[O]pencode [R]edo";
      })
    ];
  };
}
