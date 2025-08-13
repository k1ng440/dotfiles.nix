{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf (config.machine.windowManager.enabled) {
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = false;
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-gtk
        ] ++ lib.optionals config.machine.windowManager.hyprland.enable [
          inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
        ] ++ lib.optionals config.machine.windowManager.sway.enable [
          pkgs.xdg-desktop-portal-wlr
        ];
        config = {
          common.default = [ "gtk" ];
          hyprland = lib.mkIf config.machine.windowManager.hyprland.enable {
            "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          };
          sway = lib.mkIf config.machine.windowManager.sway.enable {
            "org.freedesktop.impl.portal.OpenURI" = "gtk";
            "org.freedesktop.impl.portal.Settings" = "gtk";
            "org.freedesktop.impl.portal.Screencast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
            "org.freedesktop.impl.portal.GlobalShortcuts" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
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
