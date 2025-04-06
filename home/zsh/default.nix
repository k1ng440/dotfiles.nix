{
  variables,
  config,
  ...
}: {
  programs.zsh = {enable = true;};

  home.file = {
    ".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}"
      + (builtins.toPath "/home/zsh/config/.zshrc");
    ".p10k.zsh".source =
      config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}"
      + (builtins.toPath "/home/zsh/config/.p10k.zsh");
  };
}
