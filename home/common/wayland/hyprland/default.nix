{ lib, machine, ... }:
{
  imports = [] ++ lib.optionals machine.windowManager.hyprland.enable [
      ./animations-end4.nix
      ./binds.nix
      ../common/hypridle.nix
      ../common/hyprlock.nix
      ./hyprland.nix
      ./pyprland.nix
      ./windowrules.nix
    ];
}
