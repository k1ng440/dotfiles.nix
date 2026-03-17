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
      name = lib.mkForce "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = lib.mkForce "rose-pine";
      package = lib.mkForce pkgs.rose-pine-icon-theme;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
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
