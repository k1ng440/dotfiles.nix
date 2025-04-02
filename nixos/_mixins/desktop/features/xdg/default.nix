{
  desktop,
  lib,
  pkgs,
  ...
}:
{
  xdg = {
    portal = {
      # Add xset to satisfy xdg-screensaver requirements
      configPackages =
        [
          pkgs.xorg.xset
        ]
        ++ lib.optionals (desktop == "hyprland") [
          pkgs.hyprland
        ];
      extraPortals =
        lib.optionals (desktop == "i3") [
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ lib.optionals (desktop == "hyprland") [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ lib.optionals (desktop == "pantheon") [
          pkgs.pantheon.xdg-desktop-portal-pantheon
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ lib.optionals (desktop == "lomiri") [
          pkgs.lxqt.xdg-desktop-portal-lxqt
        ];
      config = {
        common = {
          default = [ "gtk" ];
        };
        i3 = lib.mkIf (desktop == "i3") {
          default = [
            "i3"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        hyprland = lib.mkIf (desktop == "hyprland") {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        pantheon = lib.mkIf (desktop == "pantheon") {
          default = [
            "pantheon"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
      enable = true;
      xdgOpenUsePortal = true;
    };
    terminal-exec = {
      enable = true;
      settings = {
        default = if desktop == "hyprland" then [ "foot.desktop" ] else [ "ghostty" ];
      };
    };
  };
  # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  '';
}
