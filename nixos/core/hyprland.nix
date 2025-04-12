{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nixconfig.desktop-environment;
in
{
  options.nixconfig.desktop-environment = {
    enable = lib.mkEnableOption "Enable Desktop Enviroment";
    hyprland = lib.mkEnableOption "Enable Hyprland Enviroment";
  };

  config = lib.mkIf (cfg.enable && cfg.hyprland) {
    programs.hyprland = {
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      # portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      enable = true;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [ kitty ];
    environment.variables = lib.mkIf (config.nixconfig.drivers.nvidia.enable) {
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
