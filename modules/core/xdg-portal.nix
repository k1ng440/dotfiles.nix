{
  lib,
  pkgs,
  config,
  ...
}:
{

  config = lib.mkIf (!config.hostSpec.isMinimal) {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config = {
        sway = {
          default = lib.mkForce [ "gtk" ];
          "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
}
