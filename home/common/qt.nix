{
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    pkgs.catppuccin-kvantum
  ];

  qt = {
    enable = true;
    style.name = "kvantum";
    # platformTheme = {
    #   name = "qtct";
    #   package = pkgs.kdePackages.qt6ct;
    # };

    qt6ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
      };
    };
  };
}
