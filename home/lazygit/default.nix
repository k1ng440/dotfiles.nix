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
}
