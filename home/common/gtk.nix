{
  config,
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
      # name = lib.mkForce "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = lib.mkForce "Tela-circle-dark";
      package = lib.mkForce pkgs.tela-circle-icon-theme;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
  };
}
