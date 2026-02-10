{ pkgs, ... }:
{
  stylix.targets.qt.enable = true;
  stylix.icons = {
    enable = true;
    package = pkgs.gruvbox-plus-icons;
    light = "Gruvbox-Plus-Light";
    dark = "Gruvbox-Plus-Dark";
  };
}
