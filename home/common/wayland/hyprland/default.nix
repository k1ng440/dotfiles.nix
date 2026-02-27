{ pkgs, config, ... }:
{
  imports = [
    ./animations-end4.nix
    ./binds.nix
    ./hyprland.nix
    ./pyprland.nix
    ./windowrules.nix
    ./scripts
  ];

  home.packages = [
    (import ./hyprgamemode.nix { inherit pkgs; })
  ];
}
