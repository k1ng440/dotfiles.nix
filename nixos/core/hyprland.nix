{lib, pkgs, config, ...}:
let
  cfg = config.desktop-environment;
in {

  options.desktop-environment = {
    enable = lib.mkEnableOption "Enable Desktop Enviroment";
    hyprland = lib.mkEnableOption "Enable Hyprland Enviroment";
  };

  config = lib.mkIf cfg.enable && cfg.hyprland {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Screensharing
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };
  };
}
