{
  pkgs,
  lib,
  ...
}:
{
  # GTK theme configuration
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = lib.mkForce "rose-pine-moon";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = lib.mkForce "rose-pine-moon";
      package = lib.mkForce pkgs.rose-pine-icon-theme;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
    gtk2.extraConfig = ''
      gtk-theme-name="rose-pine-moon"
      gtk-icon-theme-name="rose-pine-moon"
      gtk-cursor-theme-name="BreezeX-RosePine-Linux"
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "rose-pine-moon";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  xfconf.settings = {
    xsettings = {
      "Net/ThemeName" = "rose-pine-moon";
      "Net/IconThemeName" = "rose-pine-moon";
      "Gtk/PreferDarkTheme" = true;
      "Gtk/CursorThemeName" = "BreezeX-RosePine-Linux";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "rose-pine-moon";
    GTK_USE_PORTAL = 1;
  };

  home.packages = with pkgs; [
    gtk-engine-murrine
    gnome-themes-extra
    adwaita-icon-theme
    hicolor-icon-theme
    rose-pine-gtk-theme
    rose-pine-icon-theme
    xdg-user-dirs-gtk
  ];

  # Help Thunar/XFCE apps save settings
  xfconf.enable = true;
}
