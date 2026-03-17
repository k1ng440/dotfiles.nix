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
    style.name = if machine.windowManager.kde.enable then "breeze" else "kvantum";
    platformTheme.name = if machine.windowManager.kde.enable then "kde" else "qtct";
    platformTheme.package =
      if machine.windowManager.kde.enable then
        pkgs.kdePackages.plasma-integration
      else
        pkgs.kdePackages.qt6ct;

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

  # Configure Kvantum to use Rose Pine
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=RosePine
  '';
}
