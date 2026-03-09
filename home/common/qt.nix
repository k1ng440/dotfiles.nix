{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
  ];

  qt = {
    enable = true;
    platformTheme = {
      name = "qtct";
      package = pkgs.kdePackages.qt6ct;
    };

    qt6ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
      };
    };
  };
}
