{
  pkgs,
  config,
  machine,
  ...
}:
{
  home.packages = [
    pkgs.catppuccin-kvantum
    pkgs.kdePackages.breeze
    pkgs.kdePackages.plasma-integration
  ];

  qt = {
    enable = true;
    style.name = if machine.windowManager.kde.enable then "breeze" else "kvantum";
    platformTheme.name = if machine.windowManager.kde.enable then "kde" else "qtct";
    platformTheme.package =
      if machine.windowManager.kde.enable then
        pkgs.kdePackages.plasma-integration
      else
        pkgs.kdePackages.qt6ct;

    qt6ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
      };
    };
  };

  catppuccin.kvantum.enable = !machine.windowManager.kde.enable;
}
