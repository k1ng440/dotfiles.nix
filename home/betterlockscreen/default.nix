{
  pkgs,
  config,
  variables,
  ...
}: {
  home.packages = with pkgs; [
    feh
    betterlockscreen
    i3lock-color
  ];

  xdg.configFile.betterlockscreen = {
    source =
      config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}"
      + (builtins.toPath "/home/betterlockscreen/config");
  };
}
