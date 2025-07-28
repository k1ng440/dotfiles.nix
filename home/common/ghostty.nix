{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    package = pkgs.ghostty;
    settings = {
      theme = "catppuccin-mocha";
      font-family = "Berkeley Mono";
      font-style = "Regular";
      font-size = 15;
      font-thicken = true;
      cursor-style = "block";
      cursor-style-blink = false;
      clipboard-paste-protection = false;
      background-opacity = 0.8;
      gtk-single-instance = true;
      keybind = [
        "alt+h=goto_split:left"
        "alt+l=goto_split:right"
      ];
    };
  };
}
