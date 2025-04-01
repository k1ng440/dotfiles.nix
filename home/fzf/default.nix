{
  variables,
  pkgs,
  config,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
