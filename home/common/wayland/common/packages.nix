{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    swww
    grim
    slurp
    swappy
    ydotool
    xdg-terminal-exec
    xdg-utils
    cliphist
    wl-clipboard
  ];

}
