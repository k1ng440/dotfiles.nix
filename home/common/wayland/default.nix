{
  pkgs,
  ...
}:
{
  imports = [
    ./common/packages.nix
    ./common/hypridle.nix
    ./common/hyprlock.nix
    ./common/swaync.nix
    ./common/swww.nix
    ./common/swayosd.nix
    ./common/easyeffects.nix
    ./waybar/waybar-ddubs.nix
    ./noctalia.nix
    ./wlogout
    ./hyprland
    ./swaywm
    ./chromium-flags.nix
    ./fuzzel.nix
    ./dconf.nix
  ];

  home.packages = with pkgs; [
    dex # Program to generate and execute DesktopEntry files of the Application type
    xrandr
    swayosd
    qt6.qtwayland
  ];
}
