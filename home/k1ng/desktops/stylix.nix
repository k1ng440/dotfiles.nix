{ pkgs, ... }:
{
  stylix.iconTheme = {
    enable = true;
    package = pkgs.gruvbox-plus-icons;
    light = "Gruvbox-Plus-Light";
    dark = "Gruvbox-Plus-Dark";
  };
}
