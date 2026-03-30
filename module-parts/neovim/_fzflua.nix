_: {
  # nvf options can be found at:
  # https://notashelf.github.io/nvf/options.html
  vim = {
    fzf-lua = {
      enable = true;
      setupOpts = {
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
