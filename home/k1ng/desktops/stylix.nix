{ pkgs, ... }:
{
  stylix.targets.qt.enable = false;
  stylix.targets.gtk.enable = false;
  stylix.targets.gnome.enable = false;
  stylix.targets.firefox.profileNames = [ "main" ];
  stylix.icons = {
    enable = true;
    package = pkgs.gruvbox-plus-icons;
    light = "Gruvbox-Plus-Light";
    dark = "Gruvbox-Plus-Dark";
  };
}
