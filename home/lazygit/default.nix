{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    lazygit
    commitizen
  ];

  xdg.configFile.lazygit = {
    source =
      config.lib.file.mkOutOfStoreSymlink "/home/k1ng/nix-config"
      + (builtins.toPath "/home/lazygit/config");
  };
}
