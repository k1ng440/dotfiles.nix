{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    swww
    grim
    slurp
    ydotool
    xdotool # For xwayland
    xdg-terminal-exec
    xdg-utils
    cliphist
    wl-clipboard
    nwg-bar
    pinta
    gtklp
    kdePackages.okular
  ];
}
