{
  pkgs,
  config,
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
    # Stylix handles styles but we keep the Kvantum logic
    style.name = "kvantum";
    platformTheme.name = "qtct";

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
