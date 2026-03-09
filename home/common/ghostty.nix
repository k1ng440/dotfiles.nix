{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "Berkeley Mono";
      font-style = "Regular";
      font-size = 15;
      font-thicken = true;
      cursor-style = "block";
      cursor-style-blink = false;
      clipboard-paste-protection = false;
      background-opacity = 0.95;
      background-blur-radius = 20;
      gtk-single-instance = true;
      window-padding-x = 14;
      window-padding-y = 14;
      window-decoration = true;
      gtk-titlebar = true;
      gtk-toolbar-style = "flat";
      shell-integration-features = "no-cursor,ssh-env";
      keybind = [
        "alt+h=goto_split:left"
        "alt+l=goto_split:right"
      ];
    };
  };
}
