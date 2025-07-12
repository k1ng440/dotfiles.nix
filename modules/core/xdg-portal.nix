{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf (!config.hostSpec.isMinimal) {
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = false;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
        config = {
          common.default = [ "gtk" ];
          sway = {
            default = [ "gtk" ];
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
