{ lib, hostSpec, ... }:
let
  hyprland-enabled = !hostSpec.isMinimal && hostSpec.hyprland.enabled;
in
{
  imports =
    [ ]
    ++ lib.optionals hyprland-enabled [
      ./animations-end4.nix
      ./binds.nix
      ../common/hypridle.nix
      ../common/hyprlock.nix
      ./hyprland.nix
      ./pyprland.nix
      ./windowrules.nix
    ];
}
