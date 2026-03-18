{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.machine.windowManager.hyprland.enable {
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = false;
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ lib.optionals config.machine.windowManager.hyprland.enable [
          pkgs.xdg-desktop-portal-hyprland
        ];
        config = {
          common.default = [ "gtk" ];
          hyprland = lib.mkIf config.machine.windowManager.hyprland.enable {
            "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      glib
      xdg-utils
    ];
  };
}
