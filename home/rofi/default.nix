{
  pkgs,
  inputs,
  config,
  theme,
  ...
}:
let
  inherit (config.lib.formats.rasi) mkLiteral;
  foreground = mkLiteral theme.colors.fg;
  background = mkLiteral theme.colors.bg0;
  active-background = mkLiteral theme.colors.bg1;
  urgent-background = mkLiteral theme.colors.bg_yellow; # Should probably be theme.colors.bg_red
  selected-background = active-background;
  selected-urgent-background = urgent-background;
  selected-active-background = active-background;
  separatorcolor = active-background;
  bordercolor = active-background;
in
{
  programs.rofi = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.rofi;

    theme = {
      "*" = {
        font = theme.font.family + " 24";
        foreground = foreground;
        background = background;
        active-background = active-background;
        urgent-background = urgent-background;
        selected-background = active-background;
        selected-urgent-background = urgent-background;
        selected-active-background = active-background;
        separatorcolor = active-background;
        bordercolor = active-background;
      };

      "window" = {
        background-color = background;
        border = 5;
        border-radius = 10;
        border-color = active-background;
        padding = 20;
      };

      "mainbox" = {
        border = 0;
        padding = 0;
        background-color = background;
      };

      "message" = {
        border = mkLiteral "1px dash 0px 0px";
        border-color = separatorcolor;
        background-color = background;
        padding = mkLiteral "1px";
      };

      "textbox" = {
        text-color = foreground;
        background-color = background;
      };

      "listview" = {
        fixed-height = 6;
        border = mkLiteral "2px dash 0px 0px";
        border-color = bordercolor;
        background-color = background;
        spacing = mkLiteral "2px";
        scrollbar = false;
        padding = mkLiteral "2px 0px 0px";
      };

      "element-text" = {
        border = 0;
        border-color = bordercolor;
        padding = mkLiteral "1px";
      };

      "element-text normal.normal" = {
        background-color = background;
        text-color = foreground;
      };

      "element-text normal.urgent" = {
        background-color = urgent-background;
        text-color = foreground;
      };

      "element-text normal.active" = {
        background-color = active-background;
        text-color = foreground;
      };

      "element-text selected.normal" = {
        background-color = selected-background;
        text-color = foreground;
      };

      "element-text selected.urgent" = {
        background-color = selected-urgent-background;
        text-color = foreground;
      };

      "element-text selected.active" = {
        background-color = selected-active-background;
        text-color = foreground;
      };

      "element-text alternate.normal" = {
        background-color = background;
        text-color = foreground;
      };

      "element-text alternate.urgent" = {
        background-color = urgent-background;
        text-color = foreground;
      };

      "element-text alternate.active" = {
        background-color = active-background;
        text-color = foreground;
      };

      "scrollbar" = {
        width = mkLiteral "2px";
        border = 0;
        handle-width = mkLiteral "8px";
        padding = 0;
      };

      "sidebar" = {
        border = mkLiteral "2px dash 0px 0px";
        border-color = separatorcolor;
      };

      "button selected" = {
        background-color = selected-background;
        text-color = foreground;
      };

      "inputbar" = {
        spacing = 0;
        text-color = foreground;
        background-color = background;
        padding = mkLiteral "1px";

        children = map mkLiteral [
          "prompt"
          "textbox-prompt-colon"
          "entry"
          "case-indicator"
        ];
      };

      "case-indicator" = {
        spacing = 0;
        text-color = foreground;
        background-color = background;
      };

      "entry" = {
        spacing = 0;
        text-color = foreground;
        background-color = background;
      };

      "prompt" = {
        spacing = 0;
        text-color = foreground;
        background-color = background;
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = ":";
        margin = mkLiteral "0px 0.3em 0em 0em";
        text-color = foreground;
        background-color = background;
      };
    };
  };

  xdg.configFile."rofi/rofi-power-menu" = {
    source = ./config/rofi-power-menu;
  };
}
