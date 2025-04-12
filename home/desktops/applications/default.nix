{ pkgs, ... }: {
  home.packages = with pkgs; [
    slack
    zoom-us
    nautilus
    lxappearance
    arandr
    gnucash
    mpv
    font-manager
    galculator
    mission-center
    thunderbird
  ];
}
