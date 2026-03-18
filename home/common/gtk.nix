{
  pkgs,
  lib,
  ...
}:
{
  # GTK minimal configuration (Stylix handles theme/font/cursor)
  stylix.targets.gtk.enable = true;
  gtk = {
    enable = true;
    iconTheme = {
      name = lib.mkForce "rose-pine-moon";
      package = lib.mkForce pkgs.rose-pine-icon-theme;
    };
  };

  xfconf.settings = {
    xsettings = {
      "Net/IconThemeName" = "rose-pine-moon";
      "Gtk/PreferDarkTheme" = true;
    };
  };

  home.sessionVariables = {
    GTK_USE_PORTAL = 1;
  };

  # Help Thunar/XFCE apps save settings
  xfconf.enable = true;

  home.packages = [ pkgs.libadwaita ];
}
