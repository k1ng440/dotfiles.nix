{ pkgs, ... }:
{
  home.packages = with pkgs; [
    slack
    pkgs.unstable.zoom-us
    nautilus
    lxappearance
    arandr
    gnucash
    mpv
    font-manager
    galculator
    mission-center
    thunderbird
    discord
    wofi
  ];
}
