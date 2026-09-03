{
  pkgs,
  ...
}:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
  sidekick-nvim = pkgs.vimUtils.buildVimPlugin {
    inherit (sources.sidekick-nvim) pname version src;
    nvimSkipModule = [ "sidekick.docs" ];
  };
in
{
  vim = {
    extraPlugins = {
      sidekick-nvim = {
        package = sidekick-nvim;
        setup = /* lua */ ''
          require("sidekick").setup({
            nes = {
              -- NES requires GitHub Copilot LSP — disabled
              enabled = false,
            },
            cli = {
              watch = true,
              win = {
                layout = "right",
                split = { width = 85 },
              },
            },
          })
        '';
      };
    };

    luaConfigRC.sidekick-keymaps = /* lua */ ''
      vim.keymap.set({ "n", "v" }, "<leader>aa", function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end, { desc = "Sidekick: Toggle Claude" })

      vim.keymap.set({ "n", "v" }, "<leader>ap", function()
        require("sidekick.cli").prompt()
      end, { desc = "Sidekick: Send Prompt" })

      vim.keymap.set({ "n", "x", "i", "t" }, "<c-.>", function()
        require("sidekick.cli").focus()
      end, { desc = "Sidekick: Switch Focus" })
    '';
  };
}
