{
  pkgs,
  config,
  variables,
  ...
}: {
  home.packages = with pkgs; [lazygit commitizen];

  xdg.configFile.lazygit = {
    source =
      config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}"
      + (builtins.toPath "/home/lazygit/config");
  };
}
