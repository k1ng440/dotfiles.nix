{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # slack
    pkgs.unstable.zoom-us
    nautilus
    lxappearance
    arandr
    gnucash
    mpv
    font-manager
    gnome-calculator
    mission-center
    thunderbird
    discord
    signal-desktop
    wofi
  ];
}
