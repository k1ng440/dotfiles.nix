{ variables, config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
  };

  home.file = {
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}" + (builtins.toPath "/home/fzf/config/.zshrc");
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${variables.dotfilesLocation}" + (builtins.toPath "/home/fzf/config/.p10k.zsh");
  };
}
