{ pkgs, ... }:
# NixOS module to enable hyprland and adjacent packages
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprland
    kitty
    wayclip
    wayland-utils
    wayland-logout
  ];
}
