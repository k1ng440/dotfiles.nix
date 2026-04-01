{ lib, ... }:
let
  mkAction = action: lib.generators.mkLuaInline ''require("fzf-lua.actions").${action}'';
in
{
  # nvf options can be found at:
  # https://notashelf.github.io/nvf/options.html
  vim = {
    fzf-lua = {
      enable = true;
      profile = "fzf-native";
      setupOpts = {
        actions = {
          files = {
            # __unkeyed = lib.generators.mkLuaInline "true";
            "default" = mkAction "file_edit";
            "ctrl-s" = mkAction "file_split";
            "ctrl-v" = mkAction "file_vsplit";
            "ctrl-t" = mkAction "file_tabedit";
            "alt-q" = mkAction "file_edit_or_qf";
            "ctrl-q" = {
              fn = mkAction "file_sel_to_qf";
              prefix = "select-all";
            };
          };
        };

        fzf_colors = true;
        file_ignore_patterns = [
          "node_modules/"
          ".git/"
          "dist/"
          "build/"
          "target/"
          "__pycache__/"
          "%.lock"
          "%.log"
          "%.tmp"
          "%.swp"
          "%.swo"
          "%.bak"
          "%.exe"
          "%.dll"
          "%.o"
          "%.a"
          "%.so"
          "%.dylib"
          "%.jar"
          "%.class"
          "%.min.js"
          "%.min.css"
          "%.png"
          "%.jpg"
          "%.jpeg"
          "%.gif"
          "%.bmp"
          "%.svg"
          "%.ico"
          "%.pdf"
          "%.docx"
          "%.xlsx"
          "%.pptx"
        ];
      };
    };
  };
}
