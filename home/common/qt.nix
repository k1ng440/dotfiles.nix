{
  pkgs,
  config,
  machine,
  ...
}:
{
  home.packages = [
    pkgs.kdePackages.breeze
    pkgs.kdePackages.plasma-integration
    pkgs.libsForQt5.qt5ct
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.kdePackages.qtstyleplugin-kvantum
    pkgs.rose-pine-kvantum
  ];

  qt = {
    enable = true;
    # Stylix handles styles but we keep the KDE vs Kvantum logic
    style.name = if machine.windowManager.kde.enable then "breeze" else "kvantum";
    platformTheme.name = if machine.windowManager.kde.enable then "kde" else "qtct";

    qt5ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
        style = "kvantum";
      };
    };

    qt6ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
        style = "kvantum";
      };
    };
  };
}
