{ pkgs, ... }:
{
  stylix.targets.qt.enable = true;
  stylix.targets.firefox.profileNames = [ "main" ];
  stylix.icons = {
    enable = true;
    package = pkgs.gruvbox-plus-icons;
    light = "Gruvbox-Plus-Light";
    dark = "Gruvbox-Plus-Dark";
  };
}
