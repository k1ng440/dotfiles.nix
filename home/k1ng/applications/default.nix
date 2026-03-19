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
    mission-center
    thunderbird
    signal-desktop
    wofi
    gnome-calculator
    gnome-calendar
    gnome-system-monitor
    gnome-weather
    gnome-clocks
  ];
}
