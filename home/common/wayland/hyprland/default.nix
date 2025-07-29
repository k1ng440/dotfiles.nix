{ lib, machine, ... }:
{
  imports = lib.mkIf machine.hyprland.eanble [
      ./animations-end4.nix
      ./binds.nix
      ../common/hypridle.nix
      ../common/hyprlock.nix
      ./hyprland.nix
      ./pyprland.nix
      ./windowrules.nix
    ];
}
