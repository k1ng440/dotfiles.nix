{ lib, machine, ... }: {
  imports = [
    ./common/hypridle.nix
    ./common/hyprlock.nix
    ./common/swaync.nix
    ./common/swww.nix
    ./waybar/waybar-ddubs.nix
    ./wlogout
    ./hyprland
    ./swaywm
  ];
}
