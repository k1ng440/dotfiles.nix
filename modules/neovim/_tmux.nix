{
  pkgs,
  ...
}:
let
  helpers = import ./_helpers.nix null;
  inherit (helpers) mkKeymap;
in
{
  # vim-tmux-navigator - Navigation between tmux panes and vim splits
  # https://github.com/christoomey/vim-tmux-navigator
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      vim-tmux-navigator = {
        package = vim-tmux-navigator;
        setup = /* lua */ ''
          vim.g.tmux_navigator_no_mappings = 0
          vim.g.tmux_navigator_save_on_switch = 2  -- Save all buffers when switching
          vim.g.tmux_navigator_disable_when_zoomed = 1  -- Disable when tmux is zoomed
        '';
      };
    };

    # Use Ctrl-h/j/k/l to navigate between vim splits and tmux panes
    keymaps = [
      (mkKeymap "n" "<C-h>" "<cmd>TmuxNavigateLeft<cr>")
      (mkKeymap "n" "<C-j>" "<cmd>TmuxNavigateDown<cr>")
      (mkKeymap "n" "<C-k>" "<cmd>TmuxNavigateUp<cr>")
      (mkKeymap "n" "<C-l>" "<cmd>TmuxNavigateRight<cr>")
      (mkKeymap "n" "<C-\\>" "<cmd>TmuxNavigatePrevious<cr>")
    ];
  };
}
