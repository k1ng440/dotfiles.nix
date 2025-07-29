{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.machine.hyprland.enable) {
    programs.hyprland = {
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      enable = true;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [ kitty ];
  };
}
