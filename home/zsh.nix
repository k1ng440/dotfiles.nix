{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
    envExtra = "";
    initExtra = builtins.readFile ../zshrc;
  };
}
