{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installBatSyntax = true;
    clearDefaultKeybinds = false;
    package = (config.lib.nixGL.wrap ghostty.packages.${system}.default);
    settings = {
      font-size = 14;
      font-family = "Comic Code Ligatures";
      font-family-bold = "ComicCodeLigatures-Bold";
      font-family-italic = "ComicCodeLigatures-Italic";
      font-family-bold-italic = "ComicCodeLigatures-BoldItalic";
      gtk-titlebar = false;
      window-decoration = false;
      bold-is-bright = true;
      copy-on-select = false;
      cursor-style = "block";
      window-save-state = "always";
      confirm-close-surface = false;
      gtk-tabs-location = "bottom";
      gtk-single-instance = true;
      background-opacity = 0.95;
      background-blur-radius = 20;
      window-padding-x = 2;
      window-padding-y = 2;
      window-vsync = false;
      shell-integration = "zsh";
      shell-integration-features = "cursor,sudo,title";
      theme = "rose-pine";
      # config-file = [
      #   (color-schemes + "/ghostty/catppuccin-mocha")
      # ];

      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl+s>r=reload_config"
        "ctrl+s>x=close_surface"
        "ctrl+s>n=new_window"

        # Tabs
        "ctrl+s>c=new_tab"
        "ctrl+s>l=next_tab"
        "ctrl+s>h=previous_tab"
        "ctrl+s>shift+h=move_tab:-1"
        "ctrl+s>shift+l=move_tab:1"
        "ctrl+s>1=goto_tab:1"
        "ctrl+s>2=goto_tab:2"
        "ctrl+s>3=goto_tab:3"
        "ctrl+s>4=goto_tab:4"
        "ctrl+s>5=goto_tab:5"
        "ctrl+s>6=goto_tab:6"
        "ctrl+s>7=goto_tab:7"
        "ctrl+s>8=goto_tab:8"
        "ctrl+s>9=goto_tab:9"

        # Split
        "ctrl+s>\\=new_split:right"
        "ctrl+s>-=new_split:down"
        "ctrl+s>z=toggle_split_zoom"
      ];
    };
  }
}
