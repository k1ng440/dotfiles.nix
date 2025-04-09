{lib, inputs, pkgs, config, ...}:
let
  cfg = config.desktop-environment;
in {

  options.desktop-environment = {
    enable = lib.mkEnableOption "Enable Desktop Enviroment";
    hyprland = lib.mkEnableOption "Enable Hyprland Enviroment";
  };

  config = lib.mkIf (cfg.enable && cfg.hyprland) {
    programs.hyprland = {
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      enable = true;
      withUWSM = true;
      xwayland = true;
    };

    environment.systemPackages = with pkgs; [ kitty ];
  };
}
