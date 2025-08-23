{ pkgs, lib, machine, ... }: {
  imports = [
    ./common/packages.nix
    ./common/hypridle.nix
    ./common/hyprlock.nix
    ./common/swaync.nix
    ./common/swww.nix
    ./waybar/waybar-ddubs.nix
    ./wlogout
    ./hyprland
    ./swaywm
  ];

  home.packages = with pkgs; [
    dex # Program to generate and execute DesktopEntry files of the Application type
    xorg.xrandr
    swayosd
  ];
}
