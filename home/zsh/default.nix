{
  config,
  ...
}:
{
  programs.zsh = {
    enable = true;
  };

  home.file = {
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "/home/k1ng/nix-config" + (builtins.toPath "/home/zsh/config/.zshrc");
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "/home/k1ng/nix-config" + (builtins.toPath "/home/zsh/config/.p10k.zsh");
  };
}
