{ config, lib, ... }:
{
  imports = [
    ./hyprland
    ./swaywm
    ./gnome
    ./kde
  ];

  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf config.machine.windowManager.enabled {
      XDG_CONFIG_HOME = "$HOME/.config";
      GTK_USE_PORTAL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      NIXOS_OZONE_WL = "1";
    })

    (lib.mkIf
      (
        config.machine.windowManager.sway.enable
        || config.machine.windowManager.hyprland.enable
        || config.machine.windowManager.kde.enable
      )
      {
        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland";
      }
    )

    (lib.mkIf config.machine.windowManager.sway.enable {
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_DESKTOP = "sway";
    })

    (lib.mkIf config.machine.windowManager.hyprland.enable {
      XDG_CURRENT_DESKTOP = "hyprland";
      XDG_SESSION_DESKTOP = "hyprland";
    })

    (lib.mkIf config.machine.windowManager.gnome.enable {
      XDG_CURRENT_DESKTOP = "gnome";
      XDG_SESSION_DESKTOP = "gnome";
    })

    (lib.mkIf config.machine.windowManager.kde.enable {
      XDG_CURRENT_DESKTOP = "KDE";
      XDG_SESSION_DESKTOP = "KDE";
    })
  ];
}
