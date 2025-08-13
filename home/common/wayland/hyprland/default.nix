{ lib, machine, ... }:
{
  imports = [
      ./animations-end4.nix
      ./binds.nix
      ./hyprland.nix
      ./pyprland.nix
      ./windowrules.nix
    ];
}
